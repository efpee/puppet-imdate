class imdate::conf_files () {
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
   
  file {"$app_dir/conf/AREA_CATEGORIES.csv":
    source              => puppet:///modules/imdate/AREA_CATEGORIES.csv,
  } ->   
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
  file {"$app_dir/conf/imdate-ovr-service.conf":
    content             => epp('imdate/conf/imdate-ovr-service.conf.epp'),
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
  }

}
