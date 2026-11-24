# Register write

## Request

Write Multiple Registers, function code 16, on a configured TCP or RTU endpoint, for one contiguous admitted register span per request. A Model 124 storage limit may use the compound sequence on the [SunSpec controls page](../sunspec/controls-v1.md). The page adds no retry of its own.

The request is the Modbus Application Protocol Specification V1.1b3 function code 16. One request carries one contiguous admitted span. The page defines no second attempt.

## Outcome

| response | meaning |
| --- | --- |
| normal response echoing starting address and quantity | acknowledgement |
| exception response | rejection, with the exception code |
| no response after the request may have been sent | indeterminate |

A normal response echoes the starting address and the quantity, and that echo is the acknowledgement. An exception response is a rejection, and the exception code is retained. No response after the request may have been sent is indeterminate. Nothing is retried, and the endpoint generation is fenced as a read failure fences it.

## Readback

A later qualified read of the written points is the readback. For a compound Model 124 set, record each attempted span and the unattempted remainder, retain confirmed and uncertain effects per span, and confirm the operation only when the later evidence establishes every required intended point.
