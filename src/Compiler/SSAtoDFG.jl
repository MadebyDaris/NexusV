# NexusV DFG Graph Generation
#
#   Pipeline:
#   Julia Function
#       └─► DFG Builder  (builds a DFG Graph)
#               └─► Optimization Passes  (e.g. loop unrolling, dead code elim)
#                       └─► DFG Graph  (ready for NexusV backend)
#

