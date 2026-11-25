# Wall Connector Gen 3 RS-485 start-up — compatibility landing

Use the RS-485 site-controller protocol specification for the
[half-duplex link rules (§2.7)](rs485-site-controller-protocol.md#27-timing-and-half-duplex-rules),
[start-up state machine and firmware applicability (§3)](rs485-site-controller-protocol.md#3-start-up-exchange),
and [unspecified behavior (§12)](rs485-site-controller-protocol.md#12-not-specified-in-this-revision).

- **Entry and transitions.** On 24.44.3, MID 25.2.2, 26.18.0 and 26.34.0,
  the port starts probing when its applicable conditions are met.
  On 24.28.3, probing starts at port initialization. The start condition
  for 26.42.0 is not specified.
  On 24.44.3 and 26.34.0 the state machine distinguishes
  Stopped, Probing, ProbeExhausted and Routed. On those builds the exchange
  does not require a stored site-controller configuration, and enabling dry
  contact mode stops the port. On 24.44.3, MID 25.2.2, 26.18.0 and 26.34.0,
  a matching echo prompts the station to send the pass token and then switch
  to routed mode. The token alone does not establish that routed reception is
  active. On those four builds, every failed evaluation sends the fail token.
  The station starts another attempt after each of the first nine failures.
  On the tenth failure it still sends the fail token but makes no further
  attempt. The pass and fail transitions are not specified for 24.28.3.
  The watchdog runs separately from the port state machine (§3.5).
- **Tokens and timing.** For 24.28.3, 24.44.3, MID 25.2.2, 26.18.0 and 26.34.0,
  the tokens are `TESLA` for the probe and echo, `PASS` for pass and `FAIL`
  for fail, each followed by NUL. A peer must echo the six probe bytes
  unchanged. The probe token is also specified for 26.42.0; a `PASS` or
  `FAIL` answer is not specified for that build.
  On 24.44.3 and 26.34.0 these are plain bytes, not RTU frames:
  the tokens carry no address, function code or CRC. On those builds, if no
  echo byte is present when the probe finishes, the station waits at most a
  nominal 2 ms before evaluating the received bytes. This is not a latest
  accepted arrival time. On 26.34.0 a late echo can count in a later attempt.
  Addressed traffic follows the routed-mode and half-duplex rules, not
  the token exchange.
- **Attempt bounds and restart.** The station makes up to ten attempts on
  24.44.3, MID 25.2.2, 26.18.0 and 26.34.0. On 24.28.3 there is no attempt
  limit. On 24.44.3 the station
  evaluates conditions at start-up and on changes; an internal restart can
  start probing again even after success. Provisional on 24.44.3: with
  unchanged conditions, a peer that connects after the exchange finds no new
  probe until the station next starts or receives an internal restart request.
  For 26.34.0 and 26.42.0, §3.4 gives typical, not guaranteed, times after a
  restart request: about 6 s to a probe, if issued, and about 8 s to the
  resumption of function 100 replies.

The latest accepted echo, interval between attempts, time from start to first
probe, tolerances on nominal timings, quiet time after `PASS`, and trigger
for internal restart are **Unknown**. Whether the port can route without a
completed exchange, and whether the station sent `PASS` when a peer did not
receive it, are also **Unknown**.

The [receive-only hook](activation-observation-hook-v1.md) is optional
transport diagnostics. It never sends an echo, and its output is not a
condition of start-up or driver readiness. On 24.44.3 and 26.34.0 start-up
synchronizes the link without authenticating the peer (Provisional on 24.28.3,
MID 25.2.2 and 26.18.0). A completed exchange does not qualify a driver
operation or grant action-time authorization.
