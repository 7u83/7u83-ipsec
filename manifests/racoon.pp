# Racoon IPSec

class ipsec::racoon (
	$version = 'latest'

)inherits ipsec::racoon_params{


	package {'racoon':
		name => "$racoon_pkg",
		ensure => "$version",
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
		content => "#racoon psks\n",
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
		content => template('ipsec/racoon/racoon.conf.erb')
	}
}

define ipsec::racoon::transport (
	$local_ip,
	$remote_ip,
	$proto,
	$encryption,
	$hash,
	$dh_group,
	$psk 

)
{
	concat::fragment { "$title":
		target => "$::ipsec::racoon_params::ipsec_conf",
		content => template('ipsec/racoon/ipsec.conf.transport.erb')
	}
	
	concat::fragment { "psk_$title":
		target => "$::ipsec::racoon_params::racoon_pskfile",
		content => "$remote_ip $psk\n"
	}
}

