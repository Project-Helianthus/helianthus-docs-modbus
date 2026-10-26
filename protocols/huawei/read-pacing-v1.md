# Huawei Read Pacing and Production Acquisition V1

## Scope and evidence basis

This page is the read-pacing envelope for the three Huawei gateway paths and the
production acquisition cycle that a read-only provider follows over a supplied
session: how many connections and requests, the gap between requests, the
deadline and attempt bounds, the cycle and its order, per-child isolation,
retention and loss, and the rules for reading at a production site. The groups
that the cycle reads are on the
[monitoring contract](monitoring-readonly-v1.md), and the identity reads are on
the [SmartLogger observation](smartlogger-observed-inventory-v1.md), the
[EMMA observation](emma-observed-identity-v1.md), and the
[S-Dongle observation](sdongle-observed-identity-v1.md). The historical V1 name
implies no stability before Helianthus 1.0.

This page admits no acquisition. Every class stays default denied, and
`catalog_registered=false`, `automatic_runtime_admission=false`,
`live_qualified=false`, `support_claim=false`, and `write_authority=false` are
unchanged. A provider that follows this page still needs the admission and the
operator approvals that the linked pages require. On the S-Dongle path the
recorded stop stays in force until a same-class run matches the whole tuple on
one connection generation. The registry companion for the providers is
helianthus-modbusreg issue 349.

The evidence is the bounded read-only runs behind the three observation pages,
and the monitoring run per path that the monitoring contract describes. Each
run used one connection, one request in flight, a deadline of five seconds per
attempt, and at most four attempts per request. Timeouts, transport errors,
undecodable frames, and the exception codes 5, 6, and 11 were repeated, after 1,
2, and 4 s at the SmartLogger and the EMMA and after 5, 10, and 15 s at the
S-Dongle. Other exceptions were recorded and not repeated. The gap between requests
was 750 ms at the SmartLogger and the EMMA, and 5 s at the S-Dongle. The grades
are those of the monitoring contract: Proven needs a live observation, a fact
that only a document states is never Proven, and Unknown means that neither
source settles it.

| Path | Monitoring run | Connections | Wire attempts | Duration |
| --- | --- | --- | --- | --- |
| SmartLogger | 76 requests, 59 answered with data, 17 exceptions | 1 | 88, of which 12 are inventory pages beyond the first; no repeat | about 67 s |
| EMMA | 46 requests, 37 answered with data, 9 exceptions | 1 | 50, of which 4 are inventory pages beyond the first; no repeat | about 39 s |
| S-Dongle | 31 requests, 25 answered with data, 2 exceptions, 4 timeouts | 1 | 44 | about 369 s, 200 s of it the four unit 0 timeouts |

## Shared envelope

| ID | Statement | Grade |
| --- | --- | --- |
| PE-01 | Every request of each monitoring run was carried on one TCP connection, with one request in flight, and the gateway answered under that discipline on all three paths. | Proven |
| PE-02 | The consulted editions of the three gateway families each state a response deadline of five seconds. The longest reply observed in an answered run took about 1.9 s, at the S-Dongle child. | Proven (observed replies); documentary deadline |
| PE-03 | Apart from the first request of an S-Dongle connection (PD-01), every exception arrived as a reply within the same latency band as data replies, so an exception did not need the deadline to expire. | Proven |
| PE-04 | The consulted editions bound an FC03 read at 1 to 125 registers. The largest group on the monitoring contract is 46 registers, and the largest observed group answered with data is 33 (the SmartLogger AC group). | Proven (observed groups); documentary bound |
| PE-05 | The consulted gateway editions state a frame maximum of 256 bytes. The groups of the monitoring contract stay far below it, while the SmartLogger's inventory pages exceed it (SL-14), so the documented maximum does not bound a tolerant reader. | Proven |
| PE-06 | At the EMMA, a client that the gateway does not allow is accepted at the TCP level and reset or closed after each request (EM-56). | Hypothesis |
| PE-07 | The effect of a second client on the same gateway, such as the vendor's cloud service, and the shortest sustainable gap and cycle on any path. | Unknown |

Contract rules that apply to every path:

1. **One connection.** A provider owns exactly one connection per endpoint and
   never opens a second. A reconnect closes the current connection first and
   starts a new connection generation.
2. **One request in flight.** The next request is written only after the reply
   to the current one, or its deadline, and then the path's gap.
3. **Deadline.** Each attempt has a deadline of five seconds, the value that the
   consulted editions state. A shorter deadline would have failed the S-Dongle
   child's monitoring reads.
4. **Attempts.** A timeout, a transport error, an undecodable frame, and the
   exception codes 5, 6, and 11 are failed attempts, repeated at most three
   times with the path's backoff: 1, 2, and 4 s at the SmartLogger and the EMMA,
   and 5, 10, and 15 s at the S-Dongle, as observed. Any other exception is a
   definitive reply: it is recorded, retained, and not repeated in the cycle. A
   connection reset or close after a written request is a failed attempt, never
   evidence of absence.
5. **Extent.** A read is exactly one group or identity read of the linked pages.
   Groups are never merged into a longer read, and a refused group is never split
   into reads that the monitoring contract does not list.

## SmartLogger pacing

| ID | Statement | Grade |
| --- | --- | --- |
| PS-01 | At a gap of 750 ms, 76 requests on one connection were answered on their first attempt, 59 with data and 17 with an exception. | Proven |
| PS-02 | The first request on the connection, the counter read at unit 0, was answered on its first attempt, so no settle time after connect was needed. FC03 replies took 15 to 85 ms. | Proven |
| PS-03 | A whole inventory enumeration with its counter bracket took 15 exchanges in under 11 s (SL-17). | Proven |
| PS-04 | Whether the counter moves when the listing changes (SL-03), the shortest gap the logger sustains, and its behavior under a concurrent client. | Unknown |

The V300R025C10 edition requires an interval of at least 200 ms between two
consecutive query commands. The V300R024C10SPC191 edition states no interval.
The observed gap of 750 ms meets both editions.

Contract for the SmartLogger path:

1. **Gap.** 750 ms, the observed gap. It is never shortened below that until an
   observation shows a shorter gap answered, and never below the 200 ms of the
   V300R025C10 edition.
2. **Cycle.** A recommended cycle of 60 s (Hypothesis: the maximum sustained
   cycle was not measured). A cycle reads the counter and then three groups at
   each listed and allowed inverter, 25 reads for the observed eight inverters,
   about 19 s at the gap. When the read time of a cycle would exceed three
   quarters of the cycle, the cycle is lengthened; the gap is never shortened.
3. **Guard.** Each cycle starts with the counter read at unit 0, as the
   guard-counter rule of the [gateway contract](gateway-readonly-v1.md) orders.
4. **Re-enumeration.** On a changed counter, the cycle sends no routed read, and
   the next cycle runs one enumeration under the full counter bracket and then
   the routed identity reads. At most one enumeration runs per cycle. After
   three consecutive cycles whose bracket is unstable, the endpoint is
   `listing_unstable` and waits ten cycles before it tries again (Hypothesis:
   the counter never moved in any observation).
5. **Identity.** Identity and the listing are read at start, after a reconnect,
   and after a counter change, never otherwise.

## EMMA pacing

| ID | Statement | Grade |
| --- | --- | --- |
| PM-01 | At a gap of 750 ms, 46 requests on one connection were answered on their first attempt, 37 with data and 9 with an exception. | Proven |
| PM-02 | The first request on a fresh connection was answered on its first attempt (EM-59). FC03 replies took 9 to 581 ms, and one exception reply in the identity run took about 0.7 s. | Proven |
| PM-03 | From a capture host routed through another network, the summary of a refused run reports a TCP connect latency of about two seconds. The record holds no per-connection timing. | Hypothesis |
| PM-04 | Four refused runs received no Modbus reply: 311 of their 320 attempts were reset or closed by the peer after the request was written, whatever the request and the unit, and the other nine timed out (EM-53, EM-54). | Proven |
| PM-05 | Which register, if any, guards an EMMA listing (EM-32). | Unknown |

Contract for the EMMA path:

1. **Connect.** A connect attempt is allowed the same five seconds as a request,
   so a routed host's slower connect is not a failure (Hypothesis, PM-03).
2. **Gap and cycle.** 750 ms and a recommended cycle of 60 s. A cycle reads the
   three EMMA unit 0 site groups once they are observed, then three groups at
   each listed and allowed inverter, nine reads for the observed site.
3. **No guard.** The listing is read at start and after each reconnect only, and
   the gateway contract's rule that an unbracketed listing stays unconfirmed
   applies. A listing re-read that fails withholds every child of the endpoint
   for that cycle.
4. **Refusal signature.** When every request of a cycle ends with a reset or
   close after the write, the endpoint is `INSUFFICIENT_EVIDENCE` for the cycle,
   the provider waits at least one cycle, doubling the wait up to ten cycles, and
   it never scans or falls back. The operator checks the gateway's client
   allowlist.

## S-Dongle pacing

| ID | Statement | Grade |
| --- | --- | --- |
| PD-01 | In four sessions out of four, the first request on the connection was unanswered at its five-second deadline, and its repeat on the same connection was answered within tens of milliseconds. The fourth session is the meter run of the monitoring contract. Every later request to units 1 and 100 was answered on its first attempt. | Proven |
| PD-02 | The first request on a fresh connection goes unanswered once, whatever the request. | Hypothesis |
| PD-03 | At a gap of 5 s, the gateway unit's reads took 11 to 29 ms, the child's identity reads 13 to 47 ms, and the child's monitoring groups 17 to 1881 ms, with a median of about 0.36 s. | Proven |
| PD-04 | Unit 0 never answered: no data and no exception on any of four attempts per request (SD-30). | Proven |
| PD-05 | The consulted S-Dongle editions name the third word of the search-sequence read (FC03 offset 37410, quantity 3, at unit 100) a device change sequence number. It read the same value before and after the probes of one run (SD-07). Whether it changes when the child set changes is Unknown. | Proven (equal reads); change behavior Unknown |
| PD-06 | Whether a gap shorter than 5 s is sustained. | Unknown |

The consulted S-Dongle editions list values for the first word of that read,
and the observed value 4 is not among them. The read is used here only for its
third word and for the search state, never to decode the first word.

Contract for the S-Dongle path, once the recorded stop is superseded:

1. **First request.** The first request of each connection generation is the
   search-sequence read at unit 100. It may take one extra attempt on the same
   connection, and its first timeout is not counted as a failure (Hypothesis,
   PD-02).
2. **Guard.** Each cycle starts with that read. When the state word is 0 and the
   change sequence word equals the value bound when the child was identified,
   the cycle reads the child. When either differs, or the read fails, no child
   read is sent in that cycle and the child is identified again at unit 1 in the
   next cycle (Hypothesis, PD-05).
3. **Gap and deadline.** 5 s between requests, the observed gap, and the
   five-second deadline, which leaves margin over the child's longest observed
   reply of about 1.9 s.
4. **Cycle.** A recommended cycle of 60 s. A cycle reads the guard, the four
   child groups, and the two unit 100 plant groups once they are observed: seven
   reads, about 35 s at the gap.
5. **Units.** Only units 100 and 1 are addressed. Unit 0 and every other unit
   are never addressed, because unit 0 costs about 50 s per request for no
   reply.

## Production acquisition cycle

The order within a cycle is fixed, and it is the same on every path: the
gateway guard, then the gateway's own groups, then the children in ascending
unit order, and within a child its groups in the order of the monitoring
contract.

| Path | Cycle order |
| --- | --- |
| SmartLogger | counter at unit 0; logger plant groups at unit 0 once observed; at each listed and allowed inverter, the status, string, and energy groups |
| EMMA | site energy, site power, and state of charge at unit 0 once observed; at each listed and allowed inverter, the status, string, and energy groups |
| S-Dongle | search-sequence guard at unit 100; plant power and plant active power at unit 100 once observed; at unit 1, the status, string, power, and energy groups |

A group that the monitoring contract marks as planned is not part of a
production cycle until an operator-approved observation records its answer and
the monitoring contract is revised. A refused group is not part of the cycle on
a family where it was refused.

**Per-child isolation.** A failure of one child, by timeout, exception, or a
malformed reply, withholds that child for the cycle only. It never fails a
sibling or the gateway, never triggers a re-enumeration, a scan, or a sibling
repeat, and repeated failures back off that child alone. A failure of the
gateway guard or of the listing withholds every child of the endpoint for the
cycle, as the routing rules of the [gateway contract](gateway-readonly-v1.md)
state.

**Retention.** Each group's last complete reading is retained with the time of
the read that carried it, its unit, its connection generation, and the
identity it was read under. A group either decodes whole or contributes nothing
for the cycle: no field is taken from a partial or malformed reply, and a
failed group keeps its last complete reading with its original age. A fact's
freshness is the age of the reading that carried it, never the age of the
cycle. A reconnect starts a new connection generation, and no child reading is
taken in it before that child's identity is read again.

**Loss.** What is not published is named, not hidden: the planned groups until
they are observed, the refused power group on the M3 and MAP0 series, the words
of a group that the monitoring contract does not consume, the battery group of
the MAP0 series, every zero word at a battery offset, and every meter value. A
consumer sees each of them as Unknown, never as zero, empty, or false.

## Production-site rules

1. **Read only.** A provider sends FC03 reads of the groups of the monitoring
   contract and the identity reads of the observation pages, and nothing else.
   Device identification (FC2B with MEI 0x0e) is sent only for identity, at
   start and after a reconnect or a guard change. FC06, FC10, FC0x41, and FC0x17
   are never sent.
2. **Units.** Child reads go only to units in the intersection of the validated
   listing and the operator allowlist on the SmartLogger and EMMA paths, and
   only to unit 1 on the S-Dongle path. No unit is scanned or probed, and no
   read goes to a PLC, backup-box, or meter unit while it has no class
   contract.
3. **Approval.** The first run at a site, any read that the linked pages do not
   list, and any planned group need the operator's approval at action time, and
   the first such run is an observation, not production. Production follows
   only after the monitoring contract is revised.
4. **Budget.** A cycle sends at most four wire attempts per read it plans, and a
   cycle that exhausts its budget ends, keeping what it has retained. No cycle
   starts while the previous one is still running.
5. **Concurrency.** A provider does not compete with another client. A gateway
   that refuses the connection, resets it, or stops answering is backed off for
   at least one cycle, doubling the wait up to ten cycles, and it is never
   reached through a second connection.
6. **Time of day.** Every monitoring read was taken in daylight at one operating
   point. A timeout or an exception at night is a failed or refused read, not a
   device state, and no value is assumed for standby.
7. **Identity fencing.** A changed identity at a child or at the gateway fences
   the earlier readings: they stay history with their original age, and no
   reading migrates to the new identity.
8. **Public artifacts.** No capture, endpoint, address, serial number, or value
   read at a site appears in a public artifact. Fixtures are synthetic.

## Documents consulted

| Document title | Document version | Document date | Used for |
| --- | --- | --- | --- |
| SmartLogger V300R024C10SPC191 ModBus Interface Definitions | Issue 52 | 2025-06-06 | the response deadline, the frame maximum, the read quantity bound, and the absence of an interval rule |
| SmartLogger V300R025C10 ModBus Interface Definitions | Issue 01 | 2025-12-22 | the minimum interval between query commands, the response deadline, the frame maximum, and the read quantity bound |
| SmartHEMS V100R024C00 MODBUS Interface Definitions | Issue 01 | 2024-07-15 | the response deadline, the frame maximum, and the read quantity bound on the EMMA path |
| SmartHEMS V100R025C00SPC102 MODBUS Interface Definitions | Issue V100R025C00SPC102 | 2025-08-14 | the response deadline, the frame maximum, and the read quantity bound on the EMMA path |
| SDongle V200R025C00SPC120 MODBUS Interface Definitions | Issue 01 | 2025-12-23 | the response deadline, the frame maximum, the read quantity bound, and the change sequence word of PD-05 |
| SDongle V200R022CC10 MODBUS Interface Definitions | Issue 02 | 2023-04-20 | the response deadline, the frame maximum, the read quantity bound, and the change sequence word of PD-05 |
| SUN2000MC V200R023C00 Modbus Interface Definitions | Issue 01 | 2023-03-17 | the read quantity bound for the inverter groups |

The observations behind the graded rows are the runs described in the scope
section. No value, table, label, or text of the documents is reproduced here.

**Copyright note.** The information on this page that is derived from the
SmartLogger and SUN2000MC documents listed above is attributed to Huawei
Technologies Co., Ltd., which retains the copyright in those documents. This
page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

**Copyright note.** The information on this page that is derived from the
SmartHEMS and SDongle documents listed above is attributed to Huawei Digital
Power Technologies Co., Ltd., which retains the copyright in those documents.
This page states that information in its own words and does not reproduce the
documents. The CC0-1.0 dedication of this page covers its own expression only
and does not relicense those documents.

## Open questions

1. What is the shortest gap and the longest sustained cycle on each path, and
   how does a concurrent client, such as the vendor's cloud service, change them
   (PE-07)?
2. Does the SmartLogger counter or the S-Dongle change sequence word move when
   the child set changes (PS-04, PD-05)? Neither has been seen to move.
3. Is the S-Dongle's first-request non-response a property of every fresh
   connection (PD-02), and does a settle time before the first request avoid it?
4. What guards an EMMA listing (PM-05)?
5. Does a provider at the stated gap and cycle stay answered over hours, in
   standby and at night? Every run lasted minutes and was taken in daylight.
