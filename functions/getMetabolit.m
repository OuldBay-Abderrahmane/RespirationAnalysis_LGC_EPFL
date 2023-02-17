function [val] = getMetabolit(file, metabolit, index)
    % [val] = getMetabolit(file, metabolit, index)
    % Give the metabolit level depending on it name and index
    % 
    % INPUT
    % - file: file 
    % - metabolit: metabolit name
    % - index : index of patients
    %
    % OUTPUT :
    % val: metabolit value 
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023

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
        error('Metabolit Not Supported go to getMetabolit.m and add it ');
    end
end