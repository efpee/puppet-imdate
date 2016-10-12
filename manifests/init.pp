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

  $wls_user             = '',
  $wls_pass             = '',
  $wls_admin_url        = '',
  $wls_app_cluster      = 'imdateAppCluster',
  $wls_app_servers      = ['imdateAppSrv1', 'imdateAppSrv2'],
  $wls_jms_cluster      = 'imdateJmsCluster',
  $wls_jms_servers      = ['imdateJmsSrv1', 'imdateJmsSrv2', 'imdateJmsSrv3', 'imdateJmsSrv4'],
  
  $jdbc_jndi            = 'jdbc.imdate.imdateusr',
  $jdbc_url             = '',
  $jdbc_grid_url        = '',
  $jdbc_user            = '',
  $jdbc_pass            = '',
  $jdbc_url_satais      = '',
  $jdbc_user_satais     = '',
  $jdbc_pass_satais     = '',

  $smtp_host            = '127.0.0.1',
  $smtp_port            = '25',
  
  $svn_user             = '',
  $svn_pass             = '',
  $svn_tag              = '',
  $svn_server           = '',
  
  $savasnod_jolokia_host            = '',
  $savaseng_jolokia_host            = '',
  
  $retention_period_positions       = 30,
  $retention_period_savas           = 7,
  $db_partitions_to_create          = 14,
  $load_balanced_app_server_url     = '',
  $load_balanced_jms_server_url     = '',
  $load_balanced_http_server_url    = '',
  $app_managed_servers  = [],
  $jms_managed_servers  = [],
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

  $b2b3_ext_server                  = '',  
  $b2b3_int_server                  = '',
  
  $track_service_limit_by_geom      = 2000,
  $track_service_limit_by_id        = 1000,
  $track_service_query_limit        = 2000,
  
  $smart_vessel_search_limit        = 150,
  
  $sarsurpic_soft_limit = 1000,
  $sarsurpic_hard_limit = 2000,
  $sarsurpic_limit_by_hours = 24,
    
  $service_ccbr_wsdl    = '',
  $service_ccbr_user    = '',
  $service_ccbr_pass    = '',
  $service_wfs          = '',
  $service_solr         = '',
  $service_lrit_ws      = '',
  $service_zookeeper_is_master      = false,
  
  $service_ssn          = '',
  $service_ssn_ovr      = '',
  $service_ssn_ovr_auth = false,
  $service_ssn_ovr_user = '',
  $service_ssn_ovr_pass = '',
  
  $service_thetis       = '',
  $service_thetis_inspections = '',
  $service_thetis_auth  = true,
  $service_thetis_user  = '',
  $service_thetis_pass  = '',

  $service_csn   = '',


  
) {
	Exec { path 	=>
		['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/']
	}

  $packages = [ 'vim','tree','subversion','wget']
  ensure_packages($packages)

  $conf_dir             = "$app_dir/conf"
  $log_dir              = "$app_dir/logs"
  $script_dir           = "$app_dir/scripts"

  ensure_resource('group', 'oinstall', {ensure => 'present',})

  if !defined(User['oracle']) {
    ensure_resource('user', 'oracle', {
                'ensure'          => present,
                'managehome'      => true,
                'groups'          => 'oinstall',
                'require'         => Group['oinstall'],
  })}

  group {'imdate':
    ensure              => 'present',
    before              => File['/tmp/create-dirs.sh'],
  }

  user {'validation_team':
    ensure              => present,
 		managehome	        => true,
    groups              => 'imdate',
    require             => Group['imdate'],
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
    ensure              => file,
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0755',
    content             => epp('imdate/create-dirs.sh.epp'),
  } ->
    
  exec{'create_dirs':
    command             => '/tmp/create-dirs.sh',
  } -> 
  
#  $epp_templates = ['imdate.port', 'imdate-cap-reader.conf']
# 
#  file {"$app_dir/$epp_templates":
#    ensure              => file,
#    content             => template("imdate/conf/$epp_templates.erb"),
#    owner               => 'oracle',
#    group               => 'imdate',
#    backup              => true,  
#  }
   
  file {"$app_dir/conf/imdate.port":
    ensure              => file,
    content             => epp('imdate/conf/imdate.port.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',  
  } ->
  file {"$app_dir/conf/imdate-cap-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-cap-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-csn-dist-cleaner.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-csn-dist-cleaner.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-database-cleaner.conf":
    ensure              => file,
    content             => template('imdate/conf/imdate-database-cleaner.conf.erb'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
  } ->
  file {"$app_dir/conf/imdate-db-writer.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-db-writer.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-density-map-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-density-map-service.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-distribution-application.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-application.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-distribution-processors-ejb.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-processors-ejb.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-distribution-sender.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-sender.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-distribution-services.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distribution-services.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  } ->
  file {"$app_dir/conf/imdate-distributor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-distributor.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,   
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-dist-surv.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-dist-surv.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-georegistry-proxy.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-georegistry-proxy.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
    file {"$app_dir/conf/imdate-global.properties":
    ensure              => file,
    content             => epp('imdate/conf/imdate-global.properties.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate--incident.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-incident.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-isif-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-isif-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-L0L1-processor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-L0L1-processor.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-L0-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-L0-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-ovr-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ovr-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
    file {"$app_dir/conf/imdate-ovr-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ovr-service.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-positions-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-positions-service.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-report-engine-surveillance.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-report-engine-surveillance.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-sarsurpic.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-sarsurpic.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-sarsurpic-processor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-sarsurpic-processor.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
    file {"$app_dir/conf/imdate-solr-writer-mdb.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-solr-writer-mdb.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-ssn-server-ws.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ssn-server-ws.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-ssn-service.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-ssn-service.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-uncorrelated-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-uncorrelated-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-users-service-ejbws.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-users-service-ejbws.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-vds-reader.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-vds-reader.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-video.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-video.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-wup-weblogic.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-wup-weblogic.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/imdate-xquery-distributor.conf":
    ensure              => file,
    content             => epp('imdate/conf/imdate-xquery-distributor.conf.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
  file {"$app_dir/conf/OES_logging.properties":
    ensure              => file,
    content             => epp('imdate/conf/OES_logging.properties.epp'),
    owner               => 'oracle',
    group               => 'imdate',
    backup              => true,  
    mode                => '0640',
  } ->
#  exec {'change-app-dir-ownership':
#    command   => "chown -R oracle:imdate $app_dir",
#  } ->
  file {"$script_dir/svn/fetch_from_svn.sh":
    ensure              => file,
    content             => epp('imdate/svn/fetch_from_svn.sh.epp'),
    mode                => '0700',
    owner               => 'root',
    group               => 'root',
  } ->
  exec {'fetch_from_svn':
    command             => "$script_dir/svn/fetch_from_svn.sh",  
    #onlyif                  => $svn_server and $svn_user and $svn_pass and $svn_tag
  } ->

  file {"$script_dir/wlst":
		ensure	=> directory,
	} ->
	file {"$script_dir/wlst/connect.py":
		ensure	=> file,
		content	=> epp('imdate/wlst/connect.py.epp'),
		mode    => '0700',
	} ->

  exec {'fetch_jms_functions':
    command	=> "wget https://github.com/efpee/wlst/blob/master/jms_functions.py -O $script_dir/wlst/jms_functions.py",
		unless	=> "test -f $script_dir/wlst/jms_functions.py",
		require	=> Package['wget'],
  } ->
  
	file {"$script_dir/wlst/create_jms_resources.py":
		ensure	=> file,
		content	=> epp('imdate/wlst/create_jms_resources.py.epp'),
		mode    => '0755',
	} ->
	
	#file {"$script_dir/wlst/deploy_downsampling.py":
	#	ensure	=> file,
	#	content	=> epp('imdate/wlst/deploy_downsampling.py.epp'),
	#	mode    => '0755',
	#} -> 

	file {"$script_dir/wlst/create_resources.py":
		ensure	=> file,
		content	=> epp('imdate/wlst/create_resources.py.epp'),
		mode    => '0755',
	} 
  


}
