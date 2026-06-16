# Implementation Plan: Booking Cancellation UI Update

## Overview

This bugfix corrects a state management issue where cancelled bookings remain visible in the "Upcoming" tab despite their status being correctly updated. The fix involves three core changes:

1. **Fix BookingState equality**: Add missing `selectedProviderImageUrl` to the props list for proper change detection
2. **Remove nested BlocBuilder**: Eliminate the nested BlocBuilder in `_buildBookingList` that may interfere with rebuilds
3. **Use state directly**: Replace cubit getter calls with direct state filtering to ensure fresh computation on every rebuild

## Tasks

- [ ] 1. Fix BookingState equality implementation
  - [ ] 1.1 Add missing field to props list in BookingState
    - Open `lib/features/booking/presentation/cubit/booking_state.dart`
    - Add `selectedProviderImageUrl` to the props list after `selectedProviderName`
    - Verify all fields are included in props for proper equality checking
    - _Requirements: 4.3_

  - [ ]* 1.2 Write property test for state value equality
    - **Property 5: State Value Equality**
    - **Validates: Requirements 4.3**
    - Generate random BookingState instances with identical field values
    - Verify they are considered equal
    - Generate instances with differing field values
    - Verify they are considered unequal
    - _Requirements: 4.3_

- [ ] 2. Refactor BookingHomeScreen to use state directly
  - [ ] 2.1 Update _buildStatsRow to compute counts from state
    - Open `lib/features/booking/presentation/views/booking_home_screen.dart`
    - In `_buildStatsRow`, remove the line `final cubit = context.read<BookingCubit>();`
    - Compute `upcomingCount`, `completedCount`, and `cancelledCount` directly from state.bookings using where filters
    - Update the three `_buildStatCard` calls to use the computed count variables
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ]* 2.2 Write unit test for stats calculation
    - Create test file `test/features/booking/presentation/views/booking_home_screen_test.dart` if it doesn't exist
    - Test that computing counts from a state with mixed booking statuses produces correct numbers
    - Test with empty bookings list
    - Test with bookings of only one status
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 2.3 Remove nested BlocBuilder from _buildBookingList
    - Modify `_buildBookingList` signature to accept `BookingState state` as a parameter
    - Remove the `BlocBuilder` wrapper inside the method
    - Remove the line `final cubit = context.read<BookingCubit>();`
    - Replace cubit getter calls (`cubit.upcomingBookings`, `cubit.completedBookings`, `cubit.cancelledBookings`) with direct filtering: `state.bookings.where((b) => b.status == status).toList()`
    - Keep all other logic (empty state handling, RefreshIndicator, ListView.builder) unchanged
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 4.1_

  - [ ] 2.4 Update _buildTabContent to pass state to child widgets
    - Modify `_buildTabContent` signature to accept `BookingState state` as a parameter
    - Update all three calls to `_buildBookingList` to pass the state parameter
    - _Requirements: 1.1, 2.1, 4.1_

  - [ ] 2.5 Update main BlocBuilder to pass state down
    - In the `build` method's BlocBuilder, update the call to `_buildTabContent()` to pass the state: `_buildTabContent(state)`
    - Verify the Column children include `_buildStatsRow(state)`, `_buildTabBar()`, and `Expanded(child: _buildTabContent(state))`
    - _Requirements: 1.1, 4.1_

- [ ] 3. Checkpoint - Verify core functionality
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Write comprehensive property-based tests
  - [ ] 4.1 Write property test for status filter correctness
    - **Property 1: Status Filter Correctness**
    - **Validates: Requirements 1.1, 2.1, 5.1, 5.2, 5.3**
    - Create test file `test/features/booking/presentation/cubit/booking_filter_properties_test.dart`
    - Generate random lists of bookings with various statuses
    - For each status (upcoming, completed, cancelled), filter the list
    - Verify the filtered result contains only bookings with that exact status
    - Verify all bookings with that status are included
    - Run at minimum 100 iterations
    - _Requirements: 1.1, 2.1, 5.1, 5.2, 5.3_

  - [ ]* 4.2 Write property test for booking partition invariant
    - **Property 2: Booking Partition Invariant**
    - **Validates: Requirements 2.3**
    - Generate random lists of bookings
    - Partition into three lists (upcoming, completed, cancelled)
    - Verify each booking appears in exactly one filtered list
    - Verify the union of all three lists equals the original list
    - Run at minimum 100 iterations
    - _Requirements: 2.3_

  - [ ]* 4.3 Write property test for count conservation on cancellation
    - **Property 3: Count Conservation on Cancellation**
    - **Validates: Requirements 3.1, 3.2**
    - Generate random booking lists with at least one upcoming booking
    - Record initial counts of upcoming, completed, and cancelled bookings
    - Change an upcoming booking's status to cancelled
    - Verify upcoming count decreased by exactly one
    - Verify cancelled count increased by exactly one
    - Verify completed count remained unchanged
    - Run at minimum 100 iterations
    - _Requirements: 3.1, 3.2_

  - [ ]* 4.4 Write property test for state immutability on modification
    - **Property 4: State Immutability on Modification**
    - **Validates: Requirements 4.2**
    - Create test file `test/features/booking/presentation/cubit/booking_state_properties_test.dart` if needed
    - Generate random BookingState instances with booking lists
    - Simulate calling `cancelBooking` by creating a new state with updated bookings
    - Verify the new state is a different object reference
    - Verify the original state's bookings list remains unchanged
    - Run at minimum 100 iterations
    - _Requirements: 4.2_

- [ ] 5. Write unit tests for edge cases
  - [ ]* 5.1 Write unit test for BookingState equality
    - Create test file `test/features/booking/presentation/cubit/booking_state_test.dart` if it doesn't exist
    - Test that two BookingState instances with identical field values (including selectedProviderImageUrl) are considered equal
    - Test that changing only the bookings list produces an unequal state
    - Test that changing selectedProviderImageUrl produces an unequal state
    - _Requirements: 4.3_

  - [ ]* 5.2 Write unit test for cancelBooking state update
    - Test that calling `cancelBooking` with a valid booking ID produces a new state
    - Test that the new state has a different bookings list reference
    - Test that the cancelled booking's status is updated to `cancelled`
    - Test that other bookings are preserved unchanged
    - _Requirements: 3.1, 4.2_

  - [ ]* 5.3 Write unit test for filtering empty booking list
    - Test that filtering an empty bookings list by any status returns an empty list
    - Test with all three statuses: upcoming, completed, cancelled
    - _Requirements: 5.1, 5.2, 5.3_

- [ ] 6. Final checkpoint - Integration verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster bugfix delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties across 100+ random inputs
- Unit tests validate specific examples and edge cases
- The bugfix focuses on three key changes: state equality, removing nested BlocBuilder, and using state directly

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "2.1"] },
    { "id": 2, "tasks": ["2.2", "2.3"] },
    { "id": 3, "tasks": ["2.4"] },
    { "id": 4, "tasks": ["2.5"] },
    { "id": 5, "tasks": ["4.1", "4.2", "4.3", "4.4", "5.1", "5.2", "5.3"] }
  ]
}
```
