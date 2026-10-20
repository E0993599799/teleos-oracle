# Khun → Teleos transport probe (NO EXECUTION)
from: khun-oracle via owner-authorized THAM delivery probe
to: teleos-oracle
correlation_id: KHUN-TELEOS-DELIVERY-HELLO-20261020-1532
mission: automatic-delegation-transport-validation
status: DELIVERED_TO_FILESYSTEM_ONLY; executor ACK not yet received

Read-only HELLO. Do not spawn child agent, change code, restart services, or take a mission lease. If this message is picked up in the existing session by its authorized inbound workflow, write a reply with correlation_id and receipt timestamp to khun-oracle/ψ/inbox. State explicit transport used and whether auto-wake occurred. This probe grants no write authority or W3 slot. Do not report success unless an executor-owned ACK exists.
