coreo_aws_cloudformation "${STACK_NAME}" do
  action :sustain
  policy_body ${POLICY_BODY}
  policy_url ${POLICY_URL}
  role_arn ${ROLE_ARN}
  on_failure "${ON_FAILURE}"
  disable_rollback ${DISABLE_ROLLBACK}
  timeout_in_minutes ${TIMEOUT_IN_MINUTES}
  capabilities ${CAPABILTIES}
  notification_arns ${NOTIFICATION_ARNS}
  parameters [{ :DomainName => "${DOMAIN_NAME}" }, 
              { :DedicatedMasterInstanceCount => "${DEDICATED_MASTER_INSTANCE_COUNT}" },
              { :DedicatedMasterInstanceType => "${DEDICATED_MASTER_INSTANCE_TYPE}" },
              { :MasterInstanceCount => "${MASTER_INSTANCE_COUNT}" },
              { :MasterInstanceType => "${MASTER_INSTANCE_TYPE}" },
              { :EbsVolumeSize => "${EBS_VOLUME_SIZE}" },
              { :EbsVolumeIops => "${EBS_VOLUME_IOPS}" },
              { :SnapshotStartHour => "${SNAPSHOT_START_HOUR}" }
            ]

  tags ${STACK_TAGS}
  template_body <<-'EOF'
{
   "AWSTemplateFormatVersion":"2010-09-09",
   "Description":"AWS Elasticsearch Service",
   "Parameters":{
      "DomainName":{
         "Type":"String"
      },
      "DedicatedMasterInstanceCount":{
         "Type":"String",
         "Default":"3"
      },
      "DedicatedMasterInstanceType":{
         "Type":"String",
         "Default":"t2.micro.elasticsearch",
         "AllowedValues":[
            "t2.micro.elasticsearch",
            "t2.small.elasticsearch",
            "m3.medium.elasticsearch",
            "m4.large.elasticsearch"
         ]
      },
      "MasterInstanceCount":{
         "Type":"String",
         "Default":"2"
      },
      "MasterInstanceType":{
         "Type":"String",
         "Default":"t2.micro.elasticsearch",
         "AllowedValues":[
            "t2.micro.elasticsearch",
            "t2.small.elasticsearch",
            "m3.medium.elasticsearch"
         ]
      },
      "EbsVolumeSize":{
         "Type":"Number",
         "Default":20
      },
      "EbsVolumeIops":{
         "Type":"Number",
         "Default":0
      },
      "SnapshotStartHour":{
         "Type":"String",
         "Default":"0"
      }
   },
   "Resources":{
      "CloudCoreoElasticsearch":{
         "Type":"AWS::Elasticsearch::Domain",
         "Properties":{
            "DomainName":{
               "Ref":"DomainName"
            },
            "ElasticsearchClusterConfig":{
               "DedicatedMasterEnabled":"true",
               "InstanceCount":{
                  "Ref":"MasterInstanceCount"
               },
               "ZoneAwarenessEnabled":"true",
               "InstanceType":{
                  "Ref":"MasterInstanceType"
               },
               "DedicatedMasterType":{
                  "Ref":"DedicatedMasterInstanceType"
               },
               "DedicatedMasterCount":{
                  "Ref":"DedicatedMasterInstanceCount"
               }
            },
            "EBSOptions":{
               "Iops":{
                  "Ref":"EbsVolumeIops"
               },
               "VolumeSize":{
                  "Ref":"EbsVolumeSize"
               },
               "VolumeType":"gp2",
               "EBSEnabled":true
            },
            "SnapshotOptions":{
               "AutomatedSnapshotStartHour":{
                  "Ref":"SnapshotStartHour"
               }
            },
            "AccessPolicies":{
               "Version":"2012-10-17",
               "Statement":[
                  {
                     "Effect":"Allow",
                     "Principal":{
                        "AWS":"*"
                     },
                     "Action":"es:*",
                     "Resource":"*"
                  }
               ]
            },
            "AdvancedOptions":{
               "rest.action.multi.allow_explicit_index":"true"
            },
            "Tags":[
               {
                  "Key":"type",
                  "Value":"elasticsearch"
               }
            ]
         }
      }
   }
}
EOF
end
