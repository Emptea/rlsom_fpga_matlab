function ydeg = fix_to_deg(yfix, ord)
    ydeg = yfix ./ bitshift(1,ord) .* 360;