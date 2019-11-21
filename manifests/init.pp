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
	$ikedaemon = undef
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

define ipsec::transport (
	$local_ip,
	$remote_ip,
	$proto = "any",
	$psk,
	$encryption = ['aes256'],
	$hash = 'sha256',
	$p2hash = ['sha256'],
	$dh_group = 'modp2048',
	$lifetime = 3600,
)
{
	include ::ipsec
	$ikedaemon = $::ipsec::ike_daemon
	$res = "ipsec::${ikedaemon}::transport"

	Resource[$res] { "$title":
		local_ip => $local_ip,
		remote_ip => $remote_ip,
		proto => $proto,
		psk => $psk,
		encryption => $encryption,
		hash => $hash,
		p2hash => $p2hash,
		dh_group => $dh_group,
		lifetime => $lifetime
	}

}


