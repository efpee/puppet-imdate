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
  
  $jdk_dir              = '/oracle/jdk',
  
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

  $sftp_server           = '',
  $sftp_user             = '',
  $sftp_pass             = '',
  
  $run_cron_jobs        = true,
  
  $savasnod_jolokia_host            = '',
  $savaseng_jolokia_host            = '',
  
  $retention_period_positions       = 30,
  $retention_period_savas           = 7,
  $db_partitions_to_create          = 14,
  $load_balanced_app_server_url     = '',
  $load_balanced_jms_server_url     = '',
  $load_balanced_http_server_url    = '',
  $app_managed_servers              = [],
  $jms_managed_servers              = [],
  $jms_server_prefix                = 'ImdateJMSServer',
  $db_commit_treshold               = 1000,
  $db_commit_interval               = 120000,
  $cache_expiration                 = 1440,
  
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

  case $operatingsystem {
    'RedHat', 'CentOS': {$packages = ['vim-enhanced', 'tree', 'subversion', 'wget']}
    default:            {$packages = ['vim','tree','subversion','wget']}
  }
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
  }

  user {'validation_team':
    ensure              => present,
 		managehome	        => true,
    groups              => 'imdate',
    require             => Group['imdate'],
  }
  
  exec{ "create_$app_dir":
    command             => "mkdir -p $app_dir",
    before              => Exec["chown_$app_dir"],
  } 
  exec{ "create_$log_dir":
    command             => "mkdir -p $log_dir",
    before              => Exec["chown_$app_dir"],
  } 
  exec{ "create_$conf_dir":
    command             => "mkdir -p $conf_dir",
    before              => Exec["chown_$app_dir"],
  } 
  exec{ "create_$script_dir":
    command             => "mkdir -p $script_dir",
    before              => Exec["chown_$app_dir"],
  } 
  exec{ "chown_$app_dir":
    command             => "chown -R oracle:imdate $app_dir",
    require             => [User['oracle'], Group['imdate']],
  } 
    
    
  $imdate_dirs = [
    "$app_dir/aux-data", 
    "$app_dir/data",
    "$app_dir/data/acq", 
    "$app_dir/data/acq/quarantine", 
    "$app_dir/data/acq/quarantine/savasnod", 
    "$app_dir/failed", 
    "$app_dir/failed/cdf", 
    "$app_dir/failed/distribution",
    "$app_dir/failed/vds", 
    "$app_dir/incident_working_dir", 
    "$app_dir/incident_working_dir/stage", 
    "$app_dir/incident_working_dir/archive", 
    "$app_dir/incident_working_dir/error", 
    "$app_dir/jasper_templates", 
    "$app_dir/libs", 
    "$app_dir/tmp", 
    "$app_dir/tmp/cap_reports_resources", 
    "$app_dir/working_dirs", 
    "$app_dir/working_dirs/radar-isif", 
    "$app_dir/working_dirs/radar-isif/archive", 
    "$app_dir/working_dirs/radar-isif/error", 
    "$app_dir/working_dirs/radar-isif/inbox", 
    "$app_dir/working_dirs/radar-isif/stage", 
    "$app_dir/working_dirs/vds_reader", 
    "$app_dir/working_dirs/vds_reader/archive", 
    "$app_dir/working_dirs/vds_reader/error", 
    "$app_dir/working_dirs/vds_reader/inbox", 
    "$app_dir/working_dirs/vds_reader/stage", 
    "$conf_dir/wsdl", 
    "$script_dir/jobs", 
    "$script_dir/svn", 
    "$script_dir/wlst", 
  ]

  file { $imdate_dirs:
    ensure              => 'directory',
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0755',
  }

  # These should be removed after code has been refactored to allow for new file
  # locations.
  #
  
  $special_dirs = [
    "/wl_domains",
    "/wl_domains/imdate",
  ]
    
  file { $special_dirs:
    ensure              => 'directory',
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0755',
    purge               => 'false',
  }
  
  file {'/wl_domains/imdate/imdate-apps':
    ensure              => 'link',
    target              => $app_dir,
  }
  
  #
  # End of special dirs 
  
  if $run_cron_jobs {
    file {"$script_dir/jobs/csn-dist-cleaner.sh":
      ensure            => 'present',
      owner             => 'oracle',
      group             => 'imdate',
      mode              => '0755',
      content           => epp('imdate/jobs/java-runner.sh.epp', {'jarname' => 'it.acsys.imdate.csndccleaner.CsndcDistsDBCleaner', 'mainclass' => 'it.acsys.imdate.csndccleaner.CsndcDistsDBCleaner'}),
    }

    #TODO: crontabs should alternate on machines?
    cron {'dist-cleaner':
      command           => "$script_dir/jobs/csn-dist-cleaner.sh &> /dev/null",
      user              => 'oracle',
      hour              => '*/2',
      minute            => 0,
    }

    file {"$script_dir/jobs/database-cleaner.sh":
      ensure            => 'present',
      owner             => 'oracle',
      group             => 'imdate',
      mode              => '0755',
      content           => epp('imdate/jobs/java-runner.sh.epp', {'jarname' => 'imdate-database-cleaner.jar', 'mainclass' => 'it.acsys.imdate.dbcleaner.OracleDBCleaner'}),
    }
    
    #TODO: crontabs should alternate on machines?
    cron {'imdate-db-cleaner':
      command           => "$script_dir/jobs/database-cleaner.sh &> /dev/null",
      user              => 'oracle',
      hour              => 6,
      minute            => 30,
    }
    
    file {"$script_dir/jobs/incidents.sh":
      ensure            => 'present',
      owner             => 'oracle',
      group             => 'imdate',
      mode              => '0755',
      content           => epp('imdate/jobs/java-runner.sh.epp', {'jarname' => 'imdate-incident.jar', 'mainclass' => 'it.acsys.imdate.ingestion.IncidentsIngestion'}),
    }
    
    #TODO: alternate?
    cron {'incident-processing':
      command             => "$app_dir/bin/imdate-incident.sh &> /dev/null",
      user                => 'oracle',
      hour                => '*',
      minute              => '*/5',
    }
    
    file { "$script_dir/jobs/imdate-sftp.sh":
      ensure              => 'present',
      owner               => 'oracle',
      group               => 'imdate',
      mode                => '0755',
      content             => epp('imdate/jobs/imdate-sftp.sh'),
    }

    #TODO: alternate?
    cron {'imdate-sftp':
      command             => "$script_dir/jobs/imdate-sftp.sh &> /dev/null",
      user                => 'oracle',
      hour                => '*',
      minute              => '1-59/2',
    }

  }

# TODO: resolve variable scope problem in template
#  $epp_templates = ['imdate.port', 'imdate-cap-reader.conf']
# 
#  file {"$app_dir/$epp_templates":
#    content             => template("imdate/conf/$epp_templates.erb"),
#  }

  File {
    ensure              => 'present',
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0644',
    backup              => true,
  }
   
  file {"$app_dir/conf/imdate.port":
    content             => epp('imdate/conf/imdate.port.epp'),
  } ->
  file {"$app_dir/conf/imdate-cap-reader.conf":
    content             => epp('imdate/conf/imdate-cap-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-csn-dist-cleaner.conf":
    content             => epp('imdate/conf/imdate-csn-dist-cleaner.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-database-cleaner.conf":
    content             => template('imdate/conf/imdate-database-cleaner.conf.erb'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-db-writer.conf":
    content             => epp('imdate/conf/imdate-db-writer.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-density-map-service.conf":
    content             => epp('imdate/conf/imdate-density-map-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-application.conf":
    content             => epp('imdate/conf/imdate-distribution-application.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-processors-ejb.conf":
    content             => epp('imdate/conf/imdate-distribution-processors-ejb.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-sender.conf":
    content             => epp('imdate/conf/imdate-distribution-sender.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distribution-services.conf":
    content             => epp('imdate/conf/imdate-distribution-services.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-distributor.conf":
    content             => epp('imdate/conf/imdate-distributor.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-dist-surv.conf":
    content             => epp('imdate/conf/imdate-dist-surv.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-georegistry-proxy.conf":
    content             => epp('imdate/conf/imdate-georegistry-proxy.conf.epp'),
    mode                => '0600',
  } ->
    file {"$app_dir/conf/imdate-global.properties":
    content             => epp('imdate/conf/imdate-global.properties.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-incident.conf":
    content             => epp('imdate/conf/imdate-incident.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-isif-reader.conf":
    content             => epp('imdate/conf/imdate-isif-reader.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-L0L1-processor.conf":
    content             => epp('imdate/conf/imdate-L0L1-processor.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-L0-reader.conf":
    content             => epp('imdate/conf/imdate-L0-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ovr-reader.conf":
    content             => epp('imdate/conf/imdate-ovr-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-positions-service.conf":
    content             => epp('imdate/conf/imdate-positions-service.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-report-engine-surveillance.conf":
    content             => epp('imdate/conf/imdate-report-engine-surveillance.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-sarsurpic.conf":
    content             => epp('imdate/conf/imdate-sarsurpic.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-sarsurpic-processor.conf":
    content             => epp('imdate/conf/imdate-sarsurpic-processor.conf.epp'),
  } ->
    file {"$app_dir/conf/imdate-solr-writer-mdb.conf":
    content             => epp('imdate/conf/imdate-solr-writer-mdb.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ssn-server-ws.conf":
    content             => epp('imdate/conf/imdate-ssn-server-ws.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-ssn-service.conf":
    content             => epp('imdate/conf/imdate-ssn-service.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-uncorrelated-reader.conf":
    content             => epp('imdate/conf/imdate-uncorrelated-reader.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-users-service-ejbws.conf":
    content             => epp('imdate/conf/imdate-users-service-ejbws.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-vds-reader.conf":
    content             => epp('imdate/conf/imdate-vds-reader.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-video.conf":
    content             => epp('imdate/conf/imdate-video.conf.epp'),
  } ->
  file {"$app_dir/conf/imdate-wup-weblogic.conf":
    content             => epp('imdate/conf/imdate-wup-weblogic.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/imdate-xquery-distributor.conf":
    content             => epp('imdate/conf/imdate-xquery-distributor.conf.epp'),
    mode                => '0600',
  } ->
  file {"$app_dir/conf/OES_logging.properties":
    content             => epp('imdate/conf/OES_logging.properties.epp'),
  } ->
  file {"$script_dir/svn/fetch_from_svn.sh":
    content             => epp('imdate/svn/fetch_from_svn.sh.epp'),
    mode                => '0700',
  } ->
  exec {'fetch_from_svn':
    command             => "$script_dir/svn/fetch_from_svn.sh",  
    #onlyif                  => $svn_server and $svn_user and $svn_pass and $svn_tag
  } ->

	file {"$script_dir/wlst/connect.py":
		content	=> epp('imdate/wlst/connect.py.epp'),
		mode    => '0700',
	} ->

  exec {'fetch_jms_functions':
    command	=> "wget https://github.com/efpee/wlst/blob/master/jms_functions.py -O $script_dir/wlst/jms_functions.py",
		unless	=> "test -f $script_dir/wlst/jms_functions.py",
		require	=> Package['wget'],
  } ->
  
	file {"$script_dir/wlst/create_jms_resources.py":
		content	=> epp('imdate/wlst/create_jms_resources.py.epp'),
		mode    => '0755',
	} ->

  exec {'fetch_deploy_functions':
    command	=> "wget https://github.com/efpee/wlst/blob/master/deploy_functions.py -O $script_dir/wlst/deploy_functions.py",
		unless	=> "test -f $script_dir/wlst/deploy_functions.py",
		require	=> Package['wget'],
  } ->
	
	file {"$script_dir/wlst/deploy_imdate.py":
		content	=> epp('imdate/wlst/deploy_imdate.py.epp'),
		mode    => '0755',
	} -> 

	file {"$script_dir/wlst/create_resources.py":
		content	=> epp('imdate/wlst/create_resources.py.epp'),
		mode    => '0755',
	} 
  


}
