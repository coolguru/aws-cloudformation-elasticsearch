coreo_aws_cloudformation "${STACK_NAME}" do
  action :sustain
  policy_body ${CFN_POLICY_BODY}
  policy_url ${CFN_POLICY_URL}
  role_arn ${CFN_ROLE_ARN}
  on_failure "${CFN_ON_FAILURE}"
  disable_rollback ${CFN_DISABLE_ROLLBACK}
  timeout_in_minutes ${CFN_TIMEOUT_IN_MINUTES}
  capabilities ${CFN_CAPABILTIES}
  notification_arns ${CFN_NOTIFICATION_ARNS}
  parameters [{ :DomainName => "${ES_DOMAIN_NAME}" },
              { :ElasticsearchVersion => "${ES_VERSION}"}, 
              { :DedicatedMasterInstanceCount => "${ES_DEDICATED_MASTER_INSTANCE_COUNT}" },
              { :DedicatedMasterInstanceType => "${ES_DEDICATED_MASTER_INSTANCE_TYPE}" },
              { :MasterInstanceCount => "${ES_MASTER_INSTANCE_COUNT}" },
              { :MasterInstanceType => "${ES_MASTER_INSTANCE_TYPE}" },
              { :EbsVolumeSize => "${ES_EBS_VOLUME_SIZE}" },
              { :EbsVolumeIops => "${ES_EBS_VOLUME_IOPS}" },
              { :SnapshotStartHour => "${ES_SNAPSHOT_START_HOUR}" }
            ]

  tags ${CFN_TAGS}
  template_body <<-'EOF'
{
   "AWSTemplateFormatVersion":"2010-09-09",
   "Description":"AWS Elasticsearch Service",
   "Parameters":{
      "DomainName":{
         "Type":"String"
      },
      "ElasticsearchVersion":{
         "Type":"String",
         "Default":"5.1"
      },
      "DedicatedMasterInstanceCount":{
         "Type":"String",
         "Default":"3"
      },
      "DedicatedMasterInstanceType":{
         "Type":"String",
         "Default":"m4.large.elasticsearch",
         "AllowedValues":[
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
         "Default":"m4.large.elasticsearch",
         "AllowedValues":[
            "t2.small.elasticsearch",
            "m3.medium.elasticsearch",
            "m4.large.elasticsearch"
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
      "Elasticsearch":{
         "Type":"AWS::Elasticsearch::Domain",
         "Properties":{
            "DomainName":{
               "Ref":"DomainName"
            },
            "ElasticsearchVersion": {
              "Ref":"ElasticsearchVersion"
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
                        "AWS":{
                          "Fn::Join": [
                            ":",
                            [
                              "arn:aws:iam:",
                              "PLAN::cloud_account_id",
                              "root"
                            ]
                          ]
                        }
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
   },
   "Outputs": {
    "Name": {
      "Description": "Elasticsearch domain name",
      "Value": {"Ref": "Elasticsearch"}
    },
    "Domain": {
      "Description": "Elasticsearch domain endpoint",
      "Value": {"Fn::GetAtt": ["Elasticsearch", "DomainEndpoint"]}
    },
    "URL" : {
      "Value" : {"Fn::Join": ["", [
        "https://", {"Fn::GetAtt": ["Elasticsearch", "DomainEndpoint"]}
      ]]},
      "Description" : "Elasticsearch domain URL"
    }
  }
}
EOF
end

coreo_uni_util_jsrunner "extract-es-url" do
  action :run
  json_input 'COMPOSITE::coreo_aws_cloudformation.${STACK_NAME}.stack_output'
  function <<-EOH
   let es_url = ''
    if (json_input && json_input['URL']) {
        es_url = json_input['URL']
    }
    callback(es_url)
  EOH
end
