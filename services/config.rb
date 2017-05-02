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
              { :DedicatedMasterCount => "${ES_DEDICATED_MASTER_COUNT}" },
              { :DedicatedMasterType => "${ES_DEDICATED_MASTER_TYPE}" },
              { :InstanceCount => "${ES_INSTANCE_COUNT}" },
              { :InstanceType => "${ES_INSTANCE_TYPE}" },
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
         "Type":"String",
          "Default":"esdomain"
      },
      "ElasticsearchVersion":{
         "Type":"String",
         "Default":"5.1"
      },
      "DedicatedMasterCount":{
         "Type":"String",
         "Default":"2"
      },
      "DedicatedMasterType":{
         "Type":"String",
         "Default":"m3.medium.elasticsearch",
         "AllowedValues":[
            "t2.small.elasticsearch",
            "m3.medium.elasticsearch",
            "m4.large.elasticsearch"
         ]
      },
      "InstanceCount":{
         "Type":"String",
         "Default":"4"
      },
      "InstanceType":{
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
         "Default":100
      },
      "EbsVolumeIops":{
         "Type":"Number",
         "Default":0
      },
      "SnapshotStartHour":{
         "Type":"Number",
         "Default":0
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
               "ZoneAwarenessEnabled":"true",
               "InstanceCount":{
                  "Ref":"InstanceCount"
               },
               "InstanceType":{
                  "Ref":"InstanceType"
               },
               "DedicatedMasterType":{
                  "Ref":"DedicatedMasterType"
               },
               "DedicatedMasterCount":{
                  "Ref":"DedicatedMasterCount"
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
