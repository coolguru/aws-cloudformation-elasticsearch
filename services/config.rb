coreo_uni_util_jsrunner "extract-es-url" do
  action :run
  json_input '{"Domain":"search-guru-s5yt7oluodkg3a2r3ahjjc3pva.us-east-1.es.amazonaws.com","URL":"https://search-guru-s5yt7oluodkg3a2r3ahjjc3pva.us-east-1.es.amazonaws.com","Name":"guru"}'
  function <<-EOH
   let url = 'https://search-coreoes-nxy33iqpr46i26hlxnjc6yz7ga.us-east-1.es.amazonaws.com'
   let es_url = `CC_ELASTICSEARCH_URL='${url.replace(/"/g, "'")}'`;
    callback(es_url)
  EOH
end

coreo_aws_ec2_instance "test" do
  action :define
  image_id "test"
  size "test"
  security_groups ["test"]
  role "test"
  associate_public_ip false
  ssh_key "test"
  disks [
         {
           :device_name => "/dev/xvda",
           :volume_size => 250
         }
        ]
  environment_variables [
                         'COMPOSITE::coreo_uni_util_jsrunner.extract-es-url.return''
                        ]
end