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

  $wls_user             = 'weblogic',
  $wls_pass,
  $wls_admin_url,
  $wls_domain_dir       = '/wl_domains/imdate',
  
  $app_cluster          = 'imdateAppCluster',
  $app_managed_server_names   = ['imdateAppSrv1', 'imdateAppSrv2'],
  $app_managed_server_urls,
  
  $jms_cluster          = 'imdateJmsCluster',
  $jms_managed_server_names   = ['imdateJmsSrv1', 'imdateJmsSrv2', 'imdateJmsSrv3', 'imdateJmsSrv4'],
  $jms_managed_server_urls,
  
  $jdk_dir              = '/oracle/jdk',
  
  $jdbc_datasources, 
  $jdbc_grid_nodes      = [],
  
  $jdbc_user             = 'imdate',
  $jdbc_pass,
  $jdbc_url,
  $jdbc_grid_url,
  
  $jdbc_app_server_ds   = 'jdbc.imdate.imdateds',
  $jdbc_jms_server_ds   = 'jdbc.imdate.imdateds',
  
  $jms_user             = 'imdateusr',
  $jms_pass,

  $smtp_host            = '127.0.0.1',
  $smtp_port            = '25',

  $sftp_server,
  $sftp_user            = 'IMDATEInternal',
  $sftp_pass,
  
  $run_cron_jobs        = true,
  
  # -----------------------------
  # Imdate environment configuration
  # -----------------------------
  
  $savasnod_jolokia_host,
  $savaseng_jolokia_host,
  
  $retention_period_positions       = 1831,
  $retention_period_savas           = 7,
  $db_partitions_to_create          = 14,
  $load_balanced_app_server_url,
  $load_balanced_jms_server_url,
  $load_balanced_http_server_url,
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
  $distribution_ws_server,
  $distribution_ws_port             = '10180',
  $distribution_refresh             = 5000,

  $b2b3_ext_server,
  $b2b3_int_server,
  
  $track_service_limit_by_geom      = 10000,
  $track_service_limit_by_id        = 10000,
  $track_service_query_limit        = 10000,
  
  $smart_vessel_search_limit        = 150,
  
  $sarsurpic_soft_limit             = 1000,
  $sarsurpic_hard_limit             = 2000,
  $sarsurpic_limit_by_hours         = 24,
  
  $incident_correlation_requestor,
    
  $service_ccbr_wsdl,
  $service_ccbr_user,
  $service_ccbr_pass,
  
  $service_identity_user,
  
  $service_wfs,
  
  $service_solr,
  
  $service_lrit_ws,
  $service_lrit_from,
  
  $service_ssn,
  $service_ssn_ovr,
  $service_ssn_ovr_auth = false,
  $service_ssn_ovr_user,
  $service_ssn_ovr_pass,
  
  $service_thetis,
  $service_thetis_inspections,
  $service_thetis_auth  = true,
  $service_thetis_user,
  $service_thetis_pass,

  $service_csn,

  # -----------------------------
  # Application user and group
  # -----------------------------

  $oinstall_gid         = 115,
  $oracle_gid           = 115,

  # -----------------------------  
  # deployable versions
  # -----------------------------
  
  $cap_reader_version,
  $db_writer_version,
  $distributor_version,
  $l0l1_processor_version,
  $l0_reader_version,
  $ovr_reader_version,
  $sarsurpic_processor_version,
  $uncorrelated_reader_version,
  $density_map_service_version,
  $dist_surv_version,
  $distribution_application_version,
  $distribution_processors_version,
  $distribution_services_version,
  $georegistry_proxy_version,
  $ovr_service_version,
  $positions_service_version,
  $sarsurpic_version,
  $ssn_server_version,
  $ssn_service_version,
  $users_service_version,
  $video_version,
  $wup_weblogic_version,
  $db_cleaner_rpm_version,
  $incident_rpm_version,
  $xquery_distributor_rpm_version,
  $aux_data_rpm_version,
  $jolokia_version,
  
) {
	Exec { path 	=>
		['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/']
	}

  case $operatingsystem {
    'RedHat', 'CentOS': {$packages = ['vim-enhanced', 'tree', 'wget', 'lftp']}
    default:            {$packages = ['vim', 'tree', 'wget', 'lftp']}
  }
  ensure_packages($packages)

  $conf_dir             = "$app_dir/conf"
  $log_dir              = "$app_dir/logs"
  $script_dir           = "$app_dir/scripts"

  ensure_resource('group', 'oinstall', 
    {
       ensure => 'present', 
       gid => "$oinstall_gid"
    }
  )

  ensure_resource('user', 'oracle', {
    'ensure'          => present,
    'managehome'      => true,
    'groups'          => 'oinstall',
    'require'         => Group['oinstall'],
    'gid'             => "$oracle_gid",
  })

  group {'imdate':
    ensure              => 'present',
  }

  user {'validation_team':
    ensure              => present,
 		managehome	        => true,
    groups              => 'imdate',
    require             => Group['imdate'],
  }
  
  File {
    ensure              => 'present',
    owner               => 'oracle',
    group               => 'imdate',
    mode                => '0644',
    backup              => true,
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
  ]

  file { $imdate_dirs:
    ensure              => 'directory',
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
    mode                => '0755',
    purge               => 'false',
  }
  
  file {'/wl_domains/imdate/imdate-apps':
    ensure              => 'link',
    target              => $app_dir,
  }
  
  $admin_dirs = [
    "$script_dir/wlst", 
    "$script_dir/sh",
  ]
  
  file { $admin_dirs:
    ensure              => 'directory',
    mode                => '0750',
    purge               => 'true',
    owner               => 'oracle',
    group               => 'oinstall',
  }
  
  #
  # End of special dirs 
  
  if $run_cron_jobs {
    file {"$script_dir/jobs/csn-dist-cleaner.sh":
      ensure            => 'present',
      owner             => 'oracle',
      group             => 'imdate',
      mode              => '0755',
      content           => epp('imdate/jobs/java-runner.sh.epp', {'jarname' => 'imdate-csn-dist-cleaner.jar', 'mainclass' => 'it.acsys.imdate.csndccleaner.CsndcDistsDBCleaner'}),
    }

    #TODO: crontabs should alternate on machines?
#    cron {'dist-cleaner':
#      command           => "$script_dir/jobs/csn-dist-cleaner.sh &> /dev/null",
#      user              => 'oracle',
#      hour              => '*/2',
#      minute            => 0,
#    }

    if ($operatingsystem in ['RedHat', 'CentOS']) {
      package {'imdate-db-cleaner':
        provider        => rpm,
        ensure          => "$db_cleaner_rpm_version",
        source          => "$app_dir/deployments/imdate-database-cleaner-$db_cleaner_rpm_version.noarch.rpm",
      }
    
      package {'imdate-incident':
        provider        => rpm,
        ensure          => "$incident_rpm_version",
        source          => "$app_dir/deployments/imdate-incident-$incident_rpm_version.noarch.rpm",
      }

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
      content             => epp('imdate/jobs/imdate-sftp.sh.epp'),
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
   
  file {"$app_dir/conf/AREA_CATEGORIES.csv":
    source              => 'puppet:///modules/imdate/AREA_CATEGORIES.csv',
  } 
  file {"$app_dir/conf/wsdl/thetis-PublicInformationExportService.wsdl":
    source              => 'puppet:///modules/imdate/thetis-PublicInformationExportService.wsdl',
  } 
  file {"$app_dir/conf/wsdl/thetis-ShipProxyService.wsdl":
    source              => 'puppet:///modules/imdate/thetis-ShipProxyService.wsdl',
  } 
  file {"$app_dir/conf/imdate.port":
    content             => epp('imdate/conf/imdate.port.epp'),
  } 
  file {"$app_dir/conf/imdate-cap-reader.conf":
    content             => epp('imdate/conf/imdate-cap-reader.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-csn-dist-cleaner.conf":
    content             => epp('imdate/conf/imdate-csn-dist-cleaner.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-database-cleaner.conf":
    content             => template('imdate/conf/imdate-database-cleaner.conf.erb'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-db-writer.conf":
    content             => epp('imdate/conf/imdate-db-writer.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-density-map-service.conf":
    content             => epp('imdate/conf/imdate-density-map-service.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-distribution-application.conf":
    content             => epp('imdate/conf/imdate-distribution-application.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-distribution-processors-ejb.conf":
    content             => epp('imdate/conf/imdate-distribution-processors-ejb.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-distribution-sender.conf":
    content             => epp('imdate/conf/imdate-distribution-sender.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-distribution-services.conf":
    content             => epp('imdate/conf/imdate-distribution-services.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-distributor.conf":
    content             => epp('imdate/conf/imdate-distributor.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-dist-surv.conf":
    content             => epp('imdate/conf/imdate-dist-surv.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-georegistry-proxy.conf":
    content             => epp('imdate/conf/imdate-georegistry-proxy.conf.epp'),
    mode                => '0600',
  } 
    file {"$app_dir/conf/imdate-global.properties":
    content             => epp('imdate/conf/imdate-global.properties.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-incident.conf":
    content             => epp('imdate/conf/imdate-incident.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-L0L1-processor.conf":
    content             => epp('imdate/conf/imdate-L0L1-processor.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-L0-reader.conf":
    content             => epp('imdate/conf/imdate-L0-reader.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-ovr-reader.conf":
    content             => epp('imdate/conf/imdate-ovr-reader.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-ovr-service.conf":
    content             => epp('imdate/conf/imdate-ovr-service.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-positions-service.conf":
    content             => epp('imdate/conf/imdate-positions-service.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-report-engine-surveillance.conf":
    content             => epp('imdate/conf/imdate-report-engine-surveillance.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-sarsurpic.conf":
    content             => epp('imdate/conf/imdate-sarsurpic.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-sarsurpic-processor.conf":
    content             => epp('imdate/conf/imdate-sarsurpic-processor.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-ssn-server-ws.conf":
    content             => epp('imdate/conf/imdate-ssn-server-ws.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-ssn-service.conf":
    content             => epp('imdate/conf/imdate-ssn-service.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-uncorrelated-reader.conf":
    content             => epp('imdate/conf/imdate-uncorrelated-reader.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-users-service-ejbws.conf":
    content             => epp('imdate/conf/imdate-users-service-ejbws.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-video.conf":
    content             => epp('imdate/conf/imdate-video.conf.epp'),
  } 
  file {"$app_dir/conf/imdate-wup-weblogic.conf":
    content             => epp('imdate/conf/imdate-wup-weblogic.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/imdate-xquery-distributor.conf":
    content             => epp('imdate/conf/imdate-xquery-distributor.conf.epp'),
    mode                => '0600',
  } 
  file {"$app_dir/conf/OES_logging.properties":
    content             => epp('imdate/conf/OES_logging.properties.epp'),
  }

  if ($operatingsystem in ['RedHat', 'CentOS']) {
  
    package {'imdate-aux-data':
      provider        => rpm,
      ensure          => "$aux_data_rpm_version",
      source          => "$app_dir/deployments/imdate-aux-data-$aux_data_rpm_version.noarch.rpm",
    }
  
  }

	file {"$script_dir/wlst/connect.py":
		content	=> epp('imdate/wlst/connect.py.epp'),
		mode    => '0700',
		require => File["$script_dir/wlst"]
	} 
	->
  exec {'fetch_jms_functions':
    command	=> "wget https://raw.githubusercontent.com/efpee/wlst/1.0.2/jms_functions.py -O $script_dir/wlst/jms_functions.py",
		unless	=> "test -f $script_dir/wlst/jms_functions.py",
		require	=> Package['wget'],
  } 
  -> 
	file {"$script_dir/wlst/create_jms_resources.py":
		content	=> epp('imdate/wlst/create_jms_resources.py.epp'),
		mode    => '0755',
	} 
	->
  exec {'fetch_datasource_functions':
    command	=> "wget https://raw.githubusercontent.com/efpee/wlst/1.0.2/datasource_functions.py -O $script_dir/wlst/datasource_functions.py",
		unless	=> "test -f $script_dir/wlst/datasource_functions.py",
		require	=> Package['wget'],
  } 
	->
	file {"$script_dir/wlst/create_datasources.py":
		content	=> template('imdate/wlst/create_datasources.py.erb'),
		mode    => '0700',
	}  
  ->
  exec {'fetch_deploy_functions':
    command	=> "wget https://raw.githubusercontent.com/efpee/wlst/1.0.2/deploy_functions.py -O $script_dir/wlst/deploy_functions.py",
		unless	=> "test -f $script_dir/wlst/deploy_functions.py",
		require	=> Package['wget'],
  } 
	->
	file {"$script_dir/wlst/deploy_imdate.py":
		content	=> epp('imdate/wlst/deploy_imdate.py.epp'),
		mode    => '0755',
	}  
  ->
	file {"$script_dir/wlst/create_resources.py":
		content	=> epp('imdate/wlst/create_resources.py.epp'),
		mode    => '0700',
	} 
  
  file {"$script_dir/sh/set-ACLs.sh":
    content => epp('imdate/sh/set-ACLs.sh.epp'),
    mode    => '0755',
  }

  file {"$script_dir/sh/remove-ACLs.sh":
    content => epp('imdate/sh/remove-ACLs.sh.epp'),
    mode    => '0755',
  }

}
