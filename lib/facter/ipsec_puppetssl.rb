Facter.add('ipsec_puppet_ssldir') do
        setcode "puppet config print ssldir"
end
