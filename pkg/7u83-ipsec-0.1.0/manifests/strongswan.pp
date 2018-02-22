##

class ipsec::strongswan  (
	$version = 'latest',
	$enable = $::ipsec::strongswan_params::service_enable,
	$local_ip,
	$remote_ip,
	$nets,
	$proto,
	$psk,
	$lifetime,
	$hash,
	$encryption,
	$h_group,

) inherits ipsec::strongswan_params {
	
	package { 'strongswan':
		name => $pkg_name,
		provider => $pkg_provider,
		ensure => $version
	}
	
	service { 'strongswan':
		ensure => running,
		require => Package['strongswan'],
		subscribe => Concat[ "$ipsec_conf" ],
		enable => $enable
	}

	concat { "$secrets_file": 
		owner => "$secrets_usr",
		group => "$secrets_grp",
		mode  => '0600'
	}
	concat::fragment { "pskfile_header":
		target => "$secrets_file",
		order => '00',
		content => "#strongswan psks\n",
	}

	concat { "$ipsec_conf": 
	}

	concat::fragment { "ipsec_conf_header":
		target => "$ipsec_conf",
		order => '00',
		content => template('ipsec/strongswan/ipsec.conf.header.erb'),
	}
}


define ipsec::strongswan::tunnel (
	$local_ip,
	$remote_ip,
	$nets,
	$proto = "any",
	$psk 

){

	concat::fragment { "$title":
		target => "$::ipsec::strongswan_params::ipsec_conf",
		content => template('ipsec/strongswan/ipsec.conf.tunnel.erb')
	}

	concat::fragment { "$title psk":
		target => "$::ipsec::strongswan_params::secrets_file",
		content => template('ipsec/strongswan/ipsec.secrets.erb')
	}

}

