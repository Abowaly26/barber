# Requirements Document

## Introduction

This bugfix addresses a UI state synchronization issue where cancelled bookings remain visible in the "Upcoming" tab despite their status being correctly updated to "cancelled" in the application state. The fix ensures that the UI immediately reflects booking status changes and that bookings automatically appear in their appropriate status tabs.

## Glossary

- **BookingCubit**: The state management component responsible for managing booking data and operations
- **BookingState**: The immutable state object containing all booking-related data including the list of bookings
- **BookingCard**: The UI widget that displays individual booking information
- **BookingHomeScreen**: The main screen displaying booking tabs (Upcoming, Completed, Cancelled)
- **BlocBuilder**: Flutter widget that rebuilds UI when state changes
- **Status_Filter**: The computed property that filters bookings by their status (upcoming, completed, cancelled)

## Requirements

### Requirement 1: Immediate UI Update on Status Change

**User Story:** As a user, I want cancelled bookings to immediately disappear from the "Upcoming" tab, so that I see an accurate view of my upcoming appointments.

#### Acceptance Criteria

1. WHEN a user cancels a booking from the "Upcoming" tab, THE BookingHomeScreen SHALL remove the cancelled booking from the "Upcoming" list immediately
2. WHEN a booking status changes to cancelled, THE BookingHomeScreen SHALL rebuild the tab content to reflect the updated booking list
3. WHEN the cancellation confirmation dialog is dismissed after cancellation, THE BookingCard SHALL no longer be visible in the "Upcoming" tab

### Requirement 2: Cross-Tab Status Consistency

**User Story:** As a user, I want cancelled bookings to automatically appear in the "Cancelled" tab, so that I can track my cancellation history.

#### Acceptance Criteria

1. WHEN a booking is cancelled, THE BookingHomeScreen SHALL display the cancelled booking in the "Cancelled" tab
2. WHEN switching to the "Cancelled" tab after cancellation, THE BookingHomeScreen SHALL include the newly cancelled booking in the list
3. THE System SHALL ensure that a cancelled booking appears in exactly one tab at any given time

### Requirement 3: Stats Row Synchronization

**User Story:** As a user, I want the booking statistics to update immediately when I cancel a booking, so that the counts accurately reflect my current bookings.

#### Acceptance Criteria

1. WHEN a booking is cancelled, THE BookingHomeScreen SHALL decrease the "Upcoming" count by one
2. WHEN a booking is cancelled, THE BookingHomeScreen SHALL increase the "Cancelled" count by one
3. THE BookingHomeScreen SHALL update all three stat cards (Upcoming, Completed, Cancelled) whenever the booking list changes

### Requirement 4: State Propagation

**User Story:** As a developer, I want state changes to properly trigger UI rebuilds, so that the UI always reflects the current application state.

#### Acceptance Criteria

1. WHEN BookingCubit emits a new state with updated bookings, THE BlocBuilder SHALL trigger a rebuild of dependent widgets
2. THE BookingCubit SHALL emit a new state instance when the bookings list is modified
3. THE BookingState SHALL be immutable and implement proper equality checking for change detection

### Requirement 5: Filter Function Correctness

**User Story:** As a developer, I want the booking filter functions to consistently return the correct subset of bookings, so that each tab displays only bookings matching its status.

#### Acceptance Criteria

1. THE BookingCubit.upcomingBookings SHALL return only bookings where status equals BookingStatus.upcoming
2. THE BookingCubit.cancelledBookings SHALL return only bookings where status equals BookingStatus.cancelled
3. WHEN the bookings list in state changes, THE Status_Filter SHALL recompute and return the updated filtered list
