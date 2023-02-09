function [val] = getMetabolit(file, metabolit, index)
    if isequal(metabolit, 'Tau')
        val = file.metabolites.dmPFC.Tau(index);
    elseif isequal(metabolit, 'GSH')
        val = file.metabolites.dmPFC.GSH(index);
    elseif isequal(metabolit, 'GABA' )    
        val = file.metabolites.dmPFC.GABA(index);
    elseif isequal(metabolit, 'Lac')     
        val = file.metabolites.dmPFC.Lac(index);
    else
        val = NaN;
        disp('Metabolit Not Supported go to getMetabolit.m and add it ');
    end
end