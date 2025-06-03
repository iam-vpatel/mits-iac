
multibranchPipelineJob('terraform-enterprise-infra') {
    branchSources {
        git {
            id = 'terraform-enterprise-infra'
            remote('https://bitbucket.org/your-org/terraform-enterprise-infra.git')
            credentialsId('bitbucket-cred-id')
        }
    }
    triggers {
        periodic(1)
    }
    orphanedItemStrategy {
        discardOldItems {
            daysToKeep(30)
            numToKeep(10)
        }
    }
}
