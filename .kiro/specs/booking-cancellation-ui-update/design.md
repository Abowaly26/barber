# Design Document

## Overview

The booking cancellation UI bug stems from a subtle BLoC state management issue. While `BookingCubit.cancelBooking()` correctly updates the booking status in the state, the current implementation has two potential issues:

1. **State Equality Issue**: The `BookingState` class uses Equatable and includes the `bookings` list in its props. However, when we modify bookings by mapping over them, we create a new list. If Equatable performs shallow equality checking on the list reference, it should detect the change. But the `selectedProviderImageUrl` field is missing from the `props` list, suggesting incomplete equality implementation.

2. **BlocBuilder Scope Issue**: The `_buildBookingList` method wraps each tab's content in a separate BlocBuilder. However, the stats row also uses a BlocBuilder at a higher level. The nested BlocBuilders should both rebuild when state changes, but widget tree optimization might prevent proper rebuilds.

The fix involves ensuring proper state change detection and potentially refining the BlocBuilder structure for reliable UI updates.

## Architecture

The application uses the BLoC (Business Logic Component) pattern with the `flutter_bloc` package:

```
BookingCubit (State Management)
    ↓ emits
BookingState (Immutable State)
    ↓ consumed by
BlocBuilder Widgets (UI Layer)
    ↓ renders
BookingHomeScreen → TabBarView → BookingCard
```

### Current State Flow

1. User clicks "Cancel Booking" button in BookingCard
2. Confirmation dialog appears in BookingHomeScreen
3. User confirms cancellation
4. `BookingCubit.cancelBooking(bookingId)` is called
5. Cubit maps over bookings list, updating the matching booking's status
6. Cubit emits new state with updated bookings list
7. **BlocBuilder should rebuild but doesn't reliably do so**

### Root Cause Analysis

After analyzing the code, the issue is that:

1. The `BookingState.props` list is missing `selectedProviderImageUrl`, indicating incomplete equality implementation
2. The `BookingState.copyWith()` uses nullable parameters without clear flags, which can cause confusion
3. The nested BlocBuilder in `_buildBookingList` may not be necessary and could cause rebuild issues
4. The getter methods (`upcomingBookings`, `cancelledBookings`, `completedBookings`) are called on the cubit instance rather than using the state directly, which bypasses proper reactivity

## Components and Interfaces

### BookingState (Modified)

**Purpose**: Immutable state container for all booking-related data

**Key Changes**:
- Add missing `selectedProviderImageUrl` to props list
- Ensure all fields are included in equality checking

```dart
class BookingState extends Equatable {
  // ... existing fields ...
  
  @override
  List<Object?> get props => [
    services,
    filteredServices,
    bookings,
    selectedService,
    selectedProviderName,
    selectedProviderImageUrl, // ADD THIS - currently missing
    selectedDate,
    selectedTime,
    address,
    notes,
    paymentMethod,
    lastConfirmedBooking,
    searchQuery,
    selectedCategory,
    isLoading,
    isConfirming,
  ];
}
```

### BookingCubit (No Changes Required)

The `cancelBooking` method already correctly:
1. Creates a new list via `.map().toList()`
2. Emits new state with the updated list
3. Updates the booking status to `cancelled`

```dart
void cancelBooking(String bookingId) {
  final updated = state.bookings.map((b) {
    if (b.id == bookingId) {
      return b.copyWith(status: BookingStatus.cancelled);
    }
    return b;
  }).toList();
  emit(state.copyWith(bookings: updated));
}
```

### BookingHomeScreen (Modified)

**Purpose**: Display bookings in tabs with proper reactive updates

**Key Changes**:

1. **Remove nested BlocBuilder**: The `_buildBookingList` method currently wraps its content in a BlocBuilder, but the parent widget already has a BlocBuilder. Remove the nested one and use the state passed from the parent.

2. **Use state directly instead of cubit getters**: Instead of calling `cubit.upcomingBookings`, compute filtered lists directly from the state within the build method. This ensures the filtered lists are computed fresh on every rebuild.

**Current Pattern (Problematic)**:
```dart
Widget _buildBookingList(BookingStatus status) {
  return BlocBuilder<BookingCubit, BookingState>(  // Nested BlocBuilder
    builder: (context, state) {
      final cubit = context.read<BookingCubit>();
      List<BookingModel> bookings;
      
      switch (status) {
        case BookingStatus.upcoming:
          bookings = cubit.upcomingBookings;  // Calls getter on cubit
          // ...
      }
      // ...
    },
  );
}
```

**New Pattern (Correct)**:
```dart
Widget _buildBookingList(BookingStatus status, BookingState state) {  // Accept state parameter
  List<BookingModel> bookings;
  
  switch (status) {
    case BookingStatus.upcoming:
      bookings = state.bookings.where((b) => b.status == BookingStatus.upcoming).toList();
      // ...
  }
  // ...
}
```

3. **Update TabBarView to pass state**: Modify the `_buildTabContent()` method to accept state and pass it to each tab.

**Current Pattern**:
```dart
Widget _buildTabContent() {
  return TabBarView(
    controller: _tabController,
    physics: const BouncingScrollPhysics(),
    children: [
      _buildBookingList(BookingStatus.upcoming),
      _buildBookingList(BookingStatus.completed),
      _buildBookingList(BookingStatus.cancelled),
    ],
  );
}
```

**New Pattern**:
```dart
Widget _buildTabContent(BookingState state) {
  return TabBarView(
    controller: _tabController,
    physics: const BouncingScrollPhysics(),
    children: [
      _buildBookingList(BookingStatus.upcoming, state),
      _buildBookingList(BookingStatus.completed, state),
      _buildBookingList(BookingStatus.cancelled, state),
    ],
  );
}
```

4. **Update main BlocBuilder**: Pass state to child widgets.

```dart
body: BlocBuilder<BookingCubit, BookingState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const SkeletonLoader();
    }
    return Column(
      children: [
        _buildStatsRow(state),
        _buildTabBar(),
        Expanded(child: _buildTabContent(state)),  // Pass state here
      ],
    );
  },
),
```

5. **Update _buildStatsRow**: Use state parameter instead of reading cubit.

**Current Pattern**:
```dart
Widget _buildStatsRow(BookingState state) {
  final cubit = context.read<BookingCubit>();
  return Container(
    // ...
    child: Row(
      children: [
        _buildStatCard(
          icon: Icons.schedule,
          label: 'Upcoming',
          count: cubit.upcomingBookings.length,  // Uses cubit getter
          // ...
        ),
        // ...
      ],
    ),
  );
}
```

**New Pattern**:
```dart
Widget _buildStatsRow(BookingState state) {
  final upcomingCount = state.bookings.where((b) => b.status == BookingStatus.upcoming).length;
  final completedCount = state.bookings.where((b) => b.status == BookingStatus.completed).length;
  final cancelledCount = state.bookings.where((b) => b.status == BookingStatus.cancelled).length;
  
  return Container(
    // ...
    child: Row(
      children: [
        _buildStatCard(
          icon: Icons.schedule,
          label: 'Upcoming',
          count: upcomingCount,  // Uses computed value from state
          // ...
        ),
        // ...
      ],
    ),
  );
}
```

## Data Models

No changes required to data models. The `BookingModel` already has proper `copyWith` functionality and the `BookingStatus` enum is correctly defined.

## Error Handling

No new error handling is required for this bugfix. The existing error handling patterns are sufficient:

- State updates are synchronous and cannot fail
- Filter operations on lists are safe (empty lists are handled correctly)
- The UI already handles empty states with `EmptyBookingState` widget

## Testing Strategy

This bugfix requires both unit tests and property-based tests to ensure correctness.

### Unit Tests

1. **BookingState Equality Test**: Verify that two BookingState instances with identical field values are considered equal
2. **BookingState Inequality Test**: Verify that changing the bookings list produces a different state
3. **CancelBooking Updates State Test**: Verify that calling `cancelBooking` with a valid ID produces a new state
4. **CancelBooking Preserves Other Bookings Test**: Verify that cancelling one booking doesn't affect others
5. **Filter Empty List Test**: Verify that filtering an empty bookings list returns an empty list
6. **Stats Calculation Test**: Verify that computing counts from filtered lists produces correct numbers

### Property-Based Tests

Property-based tests will use the `flutter_test` package along with a Dart property-based testing library (such as `test` package with custom generators, or a dedicated library like `check`).

Each test should run at minimum 100 iterations to cover edge cases.

**Test Configuration**: Each property test must include a comment tag referencing the design property:
```dart
// Feature: booking-cancellation-ui-update, Property 1: Status filter correctness
test('property: status filter correctness', () { ... });
```

The properties are defined in the Correctness Properties section below.


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Status Filter Correctness

*For any* list of bookings and any status value (upcoming, completed, cancelled), filtering the bookings by that status SHALL return only bookings whose status field exactly matches the filter status, and SHALL include all bookings with that status.

**Validates: Requirements 1.1, 2.1, 5.1, 5.2, 5.3**

### Property 2: Booking Partition Invariant

*For any* list of bookings, when partitioned into three filtered lists (upcoming, completed, cancelled), each booking SHALL appear in exactly one filtered list, and the union of all three filtered lists SHALL equal the original booking list.

**Validates: Requirements 2.3**

### Property 3: Count Conservation on Cancellation

*For any* booking list and any booking with upcoming status, when that booking's status is changed to cancelled, the count of upcoming bookings SHALL decrease by exactly one and the count of cancelled bookings SHALL increase by exactly one, while the count of completed bookings SHALL remain unchanged.

**Validates: Requirements 3.1, 3.2**

### Property 4: State Immutability on Modification

*For any* BookingState instance and any booking cancellation operation, calling `cancelBooking` SHALL produce a new BookingState instance (different object reference) with an updated bookings list, while the original state instance SHALL remain unchanged.

**Validates: Requirements 4.2**

### Property 5: State Value Equality

*For any* two BookingState instances, they SHALL be considered equal if and only if all their field values are equal, regardless of object reference, and instances with any differing field values SHALL be considered unequal.

**Validates: Requirements 4.3**
