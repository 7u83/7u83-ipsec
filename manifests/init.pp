# Class: ipsec
# ===========================
#
# Full description of class ipsec here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'ipsec':
#    }
#
# Authors
# -------
#
# 7u83 <7u83@mail.ru>
#
# Copyright
# ---------
#
# Copyright 2018 7u83@mail.ru
#
class ipsec(
	$version = 'latest',
	$ikedaemon = undef,

        $exchange_mode = "main",

        $generate_policy =  "off",


	$ike_auth_method = "rsasig",
 
	$proposals = [
		{
			encryption => 'aes256',
			hash => 'sha256',
			dh_group => 'modp2048',
		},
	],

	# use puppet's certs and keys by default
	$ca_cert = "$ipsec_puppet_ssldir/certs/ca.pem",
	$client_cert = "$ipsec_puppet_ssldir/certs/${facts[clientcert]}.pem",
	$client_key = "$ipsec_puppet_ssldir/private_keys/${facts[clientcert]}.pem",
	$crl = "ipsec_$puppet_ssldir/crl.pem",


	$use_global = false

) inherits ipsec::params {



	if $ikedaemon == undef {	
		$ike_daemon = $default_ike_daemon
	}
	else {
		$ike_daemon = $ikedaemon
	}

	$res = "ipsec::${ike_daemon}"

	class { "$res": 
		version => $version
	}	

}

define ipsec::transport (

	$local_ip = undef,
	$local_port = 'any',

	$remote_ip,
	$remote_id = undef, 
	$remote_port = 'any',

	$proto = "any",
	$ipv6 = false,

	$exchange_mode = $ipsec::exchange_mode,

	$proposals=$ipsec::proposals,

	$encryption = ['aes256'],
	$hash = ['sha256'],
	$p2hash = ['sha256'],
	$dh_group = 'modp2048',
	$lifetime = 3600,

	# 	
	$psk = undef,

	# use puppet's certs and keys by default
	$ca_cert = $ipsec::ca_cert,
	$client_cert = $ipsec::client_cert,
	$client_key = $ipsec::client_key,
	$crl = $ipsec::crl,


)
{
	include ::ipsec
	$ikedaemon = $::ipsec::ike_daemon
	$res = "ipsec::${ikedaemon}::transport"

	Resource[$res] { "$title":
		local_ip => $local_ip,
		local_port => $local_port,
		
		remote_ip => $remote_ip,
		remote_id => $remote_id ? { undef => $remote_ip, default => $remote_id }, 
		remote_port => $remote_port,

		proto => $proto,

		exchange_mode => $exchange_mode,
		proposals => $proposals,

		encryption => $encryption,
		hash => $hash,
		p2hash => $p2hash,
		dh_group => $dh_group,
		lifetime => $lifetime,


		psk => $psk,
		ca_cert => $ca_cert,
		client_cert => $client_cert,
		client_key => $client_key,
		crl => $crl,
	}

}


define ipsec::tunnel (
	$local_ip,
	$remote_ip,
	$nets,
	$proto = "any",
	$psk,
        $hash = 'sha256',
        $encryption = 'aes256',
        $lifetime = '86400 sec',
	$dh_group = 'modp2048',

)
{
	include ::ipsec
	$ikedaemon = $::ipsec::ike_daemon
	$res = "ipsec::${ikedaemon}::tunnel"

	Resource[$res] { "$title":
		local_ip => $local_ip,
		remote_ip => $remote_ip,
		nets => $nets,
		proto => $proto,
		psk => $psk,
		lifetime => $lifetime,
		hash => $hash,
		encryption => $encryption,
		dh_group => $dh_group,
	}

}


