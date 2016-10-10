# == Class: imdate
#
# Full description of class imdate here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'imdate':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
# TODO: review. Variables should only include values that will change between environments
#
class imdate ( 
  $app_dir              = '/imdate/imdate-apps',
  $log_level            = 'INFO',
  $jdbc_jndi            = 'jdbc.imdate.imdateusr',
  $jdbc_url             = 'jdbc:oracle:thin:@pexa1cl1.emsa.local:1535/STARP',
  $jdbc_grid_url        = 'jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=pexa1cl1)(PORT=1535)))(CONNECT_DATA=(SERVICE_NAME=STARP)))',
  $jdbc_user            = 'IMDATEUSR',
  $jdbc_pass            = 'ACSPOC',
  $jdbc_url_satais      = 'jdbc:oracle:thin:@pexa1cl1.emsa.local:1535/STARP',
  $jdbc_user_satais     = 'IMDATEUSR',
  $jdbc_pass_satais     = 'ACSPOC',

  $smtp_host            = '127.0.0.1',
  $smtp_port            = '25',
  
  $savasnod_jolokia_host            = 'qvas3.emsa.local',
  $savaseng_jolokia_host            = 'qwls56.emsa.local',
  
  $retention_period_positions       = 30,
  $retention_period_savas           = 7,
  $db_partitions_to_create          = 14,
  $wls_user                         = 'imdateusr',
  $wls_pass                         = 'ACSpassword2016!',
  $load_balanced_app_server_url     = 'http://qimdate2.emsa.local:7035',
  $load_balanced_jms_server_url     = 'http://qimdate2.emsa.local:7036',
  $load_balanced_http_server_url    = 'http://qimdate2.emsa.local:7039',
  $app_managed_servers  = ['qwls51:7035','qwls52:7035'],
  $jms_managed_servers  = ['qwls51:7036','qwls51:7037','qwls52:7036','qwls52:7037'],
  $jms_server_prefix    = 'ImdateJMSServer',
  $db_commit_treshold   = 1000,
  $db_commit_interval   = 120000,
  $cache_expiration     = 1440,
  
  $distribution_processors          = 300,
  $distribution_aggregation         = 10,
  $distribution_aggregation_timeout = 3600,
  $distribution_conversion          = 3,
  $distribution_period              = 3,
  $distribution_cleaner             = 86400000,
  $distribution_cleaner_hours_count = 24,
  $distribution_redelivery_delay    = 60,
  $distribution_email               = 'noreply@emsa.europa.eu',
  $distribution_ws_server           = 'qwls52',
  $distribution_ws_port             = '10180',
  $distribution_refresh             = 5000,

  $b2b3_ext_server                  = 'http://qwls56.emsa.local:10300',  
  $b2b3_int_server                  = 'http://0.0.0.0:10300',
  
  $track_service_limit_by_geom      = 2000,
  $track_service_limit_by_id        = 1000,
  $track_service_query_limit        = 2000,
  
  $smart_vessel_search_limit        = 150,
  
  $sarsurpic_soft_limit = 1000,
  $sarsurpic_hard_limit = 2000,
  $sarsurpic_limit_by_hours = 24,
    
  $service_ccbr_wsdl    = 'http://qesb01.emsa.local:7101/CCBR/proxy/CCBRInformationService?wsdl',
  $service_ccbr_user    = 'CCBR_IMDATE',
  $service_ccbr_pass    = 'Imdate2016.!',
  $service_wfs          = 'http://qzorba1:8080/geoserver/imdate/ows',
  $service_solr         = 'http://qsolr01.emsa.local:8983/solr',
  $service_lrit_ws      = 'http://qesb01:7101/LRIT/EULRITDC/proxy/ES2LRIT',
  $service_zookeeper_is_master      = false,
  
  $service_ssn          = 'http://qwls44:7002',
  $service_ssn_ovr      = 'http://qwls44:7006',
  $service_ssn_ovr_auth = false,
  $service_ssn_ovr_user = 'liscanada',
  $service_ssn_ovr_pass = 'teste',
  
  $service_thetis       = 'http://qosb3.emsa.local:7103/Thetis_Service_Layer/Proxy_Services',
  $service_thetis_inspections       = 'https://ws.thetis-pp.emsa.europa.eu:444/thetis-data-exchange-integration-webservice',
  $service_thetis_auth       = true,
  $service_thetis_user       = 'imdate',
  $service_thetis_pass       = 'ppteste1',

  $service_csn   = 'http://twls10:7021',


  
) {

  $conf_dir             = "$app_dir/conf"
  $log_dir              = "$app_dir/logs"
  
	Exec { path 	=>
		['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/']
	}

  package {'git':
    ensure              => 'installed',
  }
  
  group {'imdate':
    ensure              => 'present',
    before              => File['/tmp/create-dirs.sh'],
  }

  #TODO: crontabs should alternate on machines?
  cron {'dist-cleaner':
    command             => "$app_dir/bin/imdate-csn-dist-cleaner.sh  &> /dev/null",
    user                => 'root',
    hour                => '*/2',
    minute              => 0,
  }
  
  #TODO: crontabs should alternate on machines?
  cron {'db-cleaner':
    command             => "$app_dir/bin/imdate-database-cleaner.sh  &> /dev/null",
    user                => 'root',
    hour                => 6,
    minute              => 30,
  }
  
  #TODO: to be enabled? alternate?
  cron {'incident-processing':
    command             => "$app_dir/bin/imdate-incident.sh  &> /dev/null",
    user                => 'root',
    hour                => '*',
    minute              => '*/5',
  }
  
  #TODO: to be enabled? alternate?
  cron {'isif-reader':
    command             => "$app_dir/bin/imdate-isif-reader.sh  &> /dev/null",
    user                => 'root',
    hour                => '*',
    minute              => '*/5',
  }
  
  #TODO: to be enabled? alternate?
  cron {'vds-reader':
    command             => "$app_dir/bin/imdate-vds-reader.sh  &> /dev/null",
    user                => 'root',
    hour                => '*',
    minute              => '*/5',
  }
  
  file {'/tmp/create-dirs.sh':
    ensure              => directory,
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0700',
    content             => epp('imdate/create-dirs.sh.epp'),
  } ->
    
  exec{'create_dirs':
    command             => '/tmp/create-dirs.sh',
  } -> 
  
  file {"$app_dir/conf/imdate.port":
    ensure              => file,
    content             => epp('imdate/conf/imdate.port.epp'),
  } ->
  file {"$app_dir/conf/imdate-cap-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-cap-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-csn-dist-cleaner.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-csn-dist-cleaner.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-database-cleaner.conf":
    ensure              => file,
    content             => template('imdate/conf/imdate-database-cleaner.conf.erb'),
  } ->
  file {"$app_dir/conf/imdate-db-writer.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-db-writer.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-density-map-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-density-map-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-application.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-application.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-processors-ejb.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-processors-ejb.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-sender.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-sender.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-services.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-services.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distributor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distributor.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-dist-surv.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-dist-surv.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-georegistry-proxy.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-georegistry-proxy.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-global.properties":
    ensure              => file,
    content             => epp('imdate/conf/imdate-global.properties.epp'),
  } ->
  file {"$app_dir/conf/imdate--incident.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-incident.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-isif-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-isif-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-L0L1-processor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-L0L1-processor.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-L0-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-L0-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ovr-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ovr-reader.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-ovr-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ovr-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-positions-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-positions-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-report-engine-surveillance.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-report-engine-surveillance.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-sarsurpic.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-sarsurpic.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-sarsurpic-processor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-sarsurpic-processor.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-solr-writer-mdb.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-solr-writer-mdb.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ssn-server-ws.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ssn-server-ws.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ssn-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ssn-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-uncorrelated-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-uncorrelated-reader.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-users-service-ejbws.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-users-service-ejbws.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-vds-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-vds-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-video.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-video.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-wup-weblogic.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-wup-weblogic.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-xquery-distributor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-xquery-distributor.conf.epp'),
  } ->
  file {"$app_dir/conf/OES_logging.properties":
    ensure              => file,
    content             => epp('imdate/conf/OES_logging.properties'),
  } ->
  exec {'change-app-dir-ownership':
    command   => "chown -R oracle:imdate $app_dir",
  }


}
