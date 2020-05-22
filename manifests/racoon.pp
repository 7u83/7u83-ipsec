# Racoon IPSec

class ipsec::racoon (
	$version = 'latest',
		

)inherits ipsec::racoon_params{


	package {'racoon':
		name => "$racoon_pkg",
		ensure => "$version",
	}

	file {$racoon_certs:
		ensure => directory,
		require => Package['racoon']
	} ->
	exec {"/bin/ln -s ${ipsec::puppet_crl} $racoon_certs/`${ipsec::openssl_cmd} crl -noout -hash < ${ipsec::puppet_crl}`.r0 && touch /tmp/i":
		creates => "/tmp/i"
	}	

	service {'racoon':
		name => "$racoon_service",
		ensure => 'running',
		require => Concat["$racoon_conf"], 
		subscribe => Concat["$racoon_conf"],
		enable => true,
	}

	service {'ipsec':
		name => "$ipsec_service",
		enable => true,
	}

	exec { "$setkey_cmd -f $ipsec_conf":
		subscribe => Concat[ "$ipsec_conf" ],
		refreshonly => true
	}	


	concat { "$racoon_conf": 
		ensure => present
	}
	
	concat::fragment { "$racoon_conf header":
		target => "$racoon_conf",
		order => '00',
		content => template('ipsec/racoon/racoon.conf.header.erb'),
	}

	$default_proposals = $::ipsec::default_proposals

#	concat::fragment { "$racoon_conf footer":
#		target => "$racoon_conf",
#		order => '99',
#		content => template('ipsec/racoon/racoon.conf.footer.erb'),	
#	}
	
	concat { "$ipsec_conf": 
		ensure => present,
		require => Package['racoon']
	}

	concat::fragment { "ipsec_conf_header":
		target => "$ipsec_conf",
		order => '00',
		content => template('ipsec/racoon/ipsec.conf.header.erb'),
	}
	
	concat { "$racoon_pskfile": 
		owner => "$racoon_usr",
		group => "$racoon_grp",
		mode  => '0600',
		ensure => present,
		require => Package['racoon']
	}

	concat::fragment { "pskfile_header":
		target => "$racoon_pskfile",
		order => '00',
		content => "# PSKs for Racoon managed by puppet\n",
	}


	if $ipsec::use_global {
		ipsec::racoon::remote {"default":
			remote_id => 'anonymous',
			exchange_mode => $ipsec::exchange_mode,
			client_cert => $ipsec::puppet_client_cert,
			client_key => $ipsec::puppet_client_key,
			ca_cert => $ipsec::puppet_ca_cert,

			proposals => $ipsec::proposals,
		}
		ipsec::racoon::sainfo {"default":
			saparam => "anonymous",
			lifetime => 3600,
			pfs_group => "modp2048",
			encryption => ["3des"],
			hash => ["md5"],
			compression => "deflate",	
		}
	}
	
	
	
}

define ipsec::racoon::remote
(
	$remote_id,
	$exchange_mode,
	$generate_policy = "off",
	$proposals,
	$order = undef,


	$ca_cert = undef,
	$client_cert = undef,
	$client_key = undef,
	$crl = undef,
	$psk = undef,


) {
	concat::fragment { "p1_$title":
		target => "$::ipsec::racoon_params::racoon_conf",
		content => template('ipsec/racoon/remote.erb')
	}
}

define ipsec::racoon::sainfo
(
	$pfs_group,
	$encryption,
	$hash,
	$compression,
	$lifetime,

	$saparam,
	$order = undef
	
){
	concat::fragment { "sainfo_$title":
		target => "$::ipsec::racoon_params::racoon_conf",
		content => template('ipsec/racoon/sainfo.erb')
	}

}

define ipsec::racoon::tunnel (
	$local_ip,
	$remote_ip,
	$encryption,
	$hash,
	$dh_group,
	$lifetime,
	$nets,
	$proto,
	$psk 
)
{
	concat::fragment { "$title":
		target => "$::ipsec::racoon_params::ipsec_conf",
		content => template('ipsec/racoon/ipsec.conf.tunnel.erb')
	}
	
	concat::fragment { "psk_$title":
		target => "$::ipsec::racoon_params::racoon_pskfile",
		content => "$remote_ip $psk\n"
	}

	concat::fragment { "racoon_conf_$title":
		target => "$::ipsec::racoon_params::racoon_conf",
		content => template('ipsec/racoon/racoon-tunnel.conf.erb')
	}
}

define ipsec::racoon::transport (
	$local_ip,
	$local_port,
	$remote_ip,
	$remote_id,
	$remote_port,
	$proto,

	$encryption,
	$hash,
	$dh_group,
	$p2hash,
	$lifetime,

	$exchange_mode,

	$psk,
	$ca_cert,
	$client_cert,
	$client_key,
	$crl,

	$proposals,
)
{
	if ! $ipsec::use_global {
		ipsec::racoon::remote {"$title":
			remote_id => $remote_id,
			exchange_mode => $exchange_mode,
			proposals => $proposals,

			psk => $psk,
			ca_cert => $ca_cert,
			client_cert => $client_cert,
			client_key => $client_key,
			crl => $crl,
		}

		if ! $local_ip {
			$arg_local_ip = "anonymous"
		}
		else{
			$arg_local_ip= "address $local_ip[$local_port] $proto"
		}


	
		ipsec::racoon::sainfo {"$title":
			saparam => "$arg_local_ip address $remote_ip[$remote_port] $proto ",
			lifetime => 3600,
			pfs_group => "modp2048",
			encryption => ["aes256"],
			hash => ["sha256"],
			compression => "deflate",	
		}
	}

	concat::fragment { "$title":
		target => "$::ipsec::racoon_params::ipsec_conf",
		content => template('ipsec/racoon/ipsec.conf.transport.erb')
	}

	if $psk {	
		concat::fragment { "psk_$title":
			target => "$::ipsec::racoon_params::racoon_pskfile",
			content => "$remote_ip $psk\n"
		}
	}



#	concat::fragment { "racoon_conf_$title":
#		target => "$::ipsec::racoon_params::racoon_conf",
#		content => template('ipsec/racoon/racoon-transport.conf.erb')
#	}

}

