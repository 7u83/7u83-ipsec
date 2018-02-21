##

class ipsec::isakmpd  (
	$version = 'latest'

) inherits ipsec::isakmpd_params {
	
	if $pkg_name != false {
#		if $pkg_provider_p != false {
#			$provider = $pkg_provider_p
#		}
#		else {
#			$provider = $pkg_provider
#		}

		package { 'isakmpd':
			name => $pkg_name,
			provider => $pkg_provider
		}
	}	


	concat { "$ipsec_conf": 
		mode  => '0600'

	}

	concat::fragment { "ipsec_conf_header":
		target => "$ipsec_conf",
		order => '00',
		content => template('ipsec/isakmpd_ipsec_conf_header.erb'),

	}

	exec { "$setkey_cmd":
		subscribe => Concat[ "$ipsec_conf" ],
		refreshonly => true
	}	



}


define ipsec::isakmpd::tunnel (
	$local_ip,
	$remote_ip,
	$nets,
	$proto = "any",
	$psk 

){
	notify { "$title:  $::ipsec::isakmpd_params::ipsec_conf": }

	concat::fragment { "$title":
		target => "$::ipsec::isakmpd_params::ipsec_conf",
		content => template('ipsec/isakmpd_tunnel.erb')
	}

}

