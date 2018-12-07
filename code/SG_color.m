function c=SG_color(beh)

switch beh
    case 'force'
        c = [0.7941    0.1020    0.1098];
    case 'success'
        c = [0.2157    0.4941    0.7216];
    case 'choice'
        c= [0.3020    0.6863    0.2902];
    case 'drift'
        c=[.4 .4 .4];
    case 'null'
        c=[.7 .7 .7];
end