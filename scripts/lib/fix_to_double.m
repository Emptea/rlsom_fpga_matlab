function yd = fix_to_double(yfix, ord)
    yd = yfix / bitshift(1,ord);