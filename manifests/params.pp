#psec::params

class ipsec::params {
	case $::osfamily {
		'FreeBSD':{
			$default_ike_daemon = 'racoon'
			$openssl_cmd = "/usr/bin/openssl"
		}
		'OpenBSD':{
			$default_ike_daemon = 'isakmpd'
			$openssl_cmd = "/usr/bin/openssl"
		}
		default: {
			$default_ike_daemon = 'strongswan'
			$openssl_cmd = "/usr/bin/openssl"
		}
	}

	$puppet_ca_cert = "$ipsec_puppet_ssldir/certs/ca.pem"
	$puppet_client_cert = "$ipsec_puppet_ssldir/certs/${facts[clientcert]}.pem"
	$puppet_client_key = "$ipsec_puppet_ssldir/private_keys/${facts[clientcert]}.pem"
	$puppet_crl = "ipsec_$puppet_ssldir/crl.pem"
	
}

