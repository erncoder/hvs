# Papa Assignment Notes

## Assumptions

- The API is okay to surface implementation details (e.g. errors) because it sits behind an API key.
- Users are allowed to create requests with a sum of minutes greater than the available minutes for that user. This is
  not an assumption that would carry into production-ready code and would need logic to prevent (e.g. minute "escrow").
- A member should not be able to create a visit request if their balance is insufficient to cover it (not just if at 0).

## Design Decisions

- Because of the prototypical nature of the project, I opted to combine the suggested `Visit` and `Transaction` tables
  (de-normalizing a bit). The `pal` column on the `Visit` table serves the multiple purposes of marking completion,
  attributing fulfillment, and preventing duplicate fulfillment without requiring joins. The main reason for this was
  for simplicity's sake.
- If a visit is fulfilled, minute deductions are floored at 0.
- I added a `mins_balance` column to the `User` table to track a user's remaining minutes. This decision could be the
  beginning of a "super" user table, but for the size of the project, it's a sensible place to locate the column.
