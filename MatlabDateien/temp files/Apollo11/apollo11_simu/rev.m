function rev = rev(x)
    rev = x - fix(x/360.0)*360.0;
    if (rev < 0.0)
        rev = rev + 360.0;
    end
end
