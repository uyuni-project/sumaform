output "sles15sp5s390_minion_configuration" {
  value = length(module.sles15sp5s390_minion) > 0 ? module.sles15sp5s390_minion[0].configuration : null
}

output "sles15sp5s390_sshminion_configuration" {
  value = length(module.sles15sp5s390_sshminion) > 0 ? module.sles15sp5s390_sshminion[0].configuration : null
}
