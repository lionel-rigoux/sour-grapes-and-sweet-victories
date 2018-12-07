function data=SG_load_data(version)

if nargin==0
    data = [SG_load_data('v1') SG_load_data('v3') SG_load_data('v2')];
else

    switch version
        case 'v1'
            data = SG_load_data_primo();
        otherwise
            data = SG_load_data_replication(version);
    end
    
    [data.version] = deal(version);

end