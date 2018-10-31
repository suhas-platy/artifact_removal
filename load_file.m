IN_PATH = 'C:\Recordings\suhas_artifact\'
COGNIONICS_SRATE = 500;
COGNIONICS_SCALE = 1;
COGNIONICS_ELECTRODE_LABELS = {'F7', 'Fp1', 'Fp2', 'F8', 'F3',...
                               'Fz', 'F4', 'C3', 'Cz', 'P8',...
                               'P7', 'Pz', 'P4', 'T3', 'P3',...
                               'O1', 'O2', 'C4', 'T4', 'A2',...
                               'ACC20', 'ACC21', 'ACC22', 'PacketCounter', 'Trigger'};
COGNIONICS_KEEP_IDX = 1:20;
COGNIONICS_KEEP_IDX_NO_GROUND = 1:19;

% blinks, saccades, forehead shurgs, neck shrugs
EPOCH_IDX = [1 5;
            6 10;
            11 15;
            16 20]

% load
xdf_files = dir( [IN_PATH filesep '*.xdf'] );
curr_xdf_file = [IN_PATH filesep xdf_files(1).name]

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% EEG = eeg_load_xdf( curr_xdf_file ); % can't pass in HandleClockSynchronization so have to do it the hard way
streams = load_xdf( curr_xdf_file, 'HandleClockSynchronization', false );
EEG = streams{1};

% keep EEGLab happy
EEG.trials = 1;
EEG.epoch = [];
EEG.event = [];
EEG.urevent = [];
EEG.chanlocs = [];
EEG.times = EEG.time_stamps;
EEG.data = EEG.time_series(COGNIONICS_KEEP_IDX,:) .* COGNIONICS_SCALE;
EEG.setname = 'XDF file';
EEG.icawinv = [];
EEG.icaweights = [];
EEG.icasphere = [];
EEG.nbchan = size( EEG.time_series, 1 );
EEG.pnts = size( EEG.time_series, 2 );
EEG.srate = COGNIONICS_SRATE;
EEG.xmax = (EEG.pnts/EEG.srate) - (1/(1.*COGNIONICS_SRATE));
EEG.xmin = 0;
EEG.icaact = [];
EEG.filepath = curr_xdf_file;
EEG.filename = 'xdf.set'

% set channel labels
for i = COGNIONICS_KEEP_IDX(1):COGNIONICS_KEEP_IDX(end)
  if ( i == COGNIONICS_KEEP_IDX(1) )
     disp( 'first' );
  end
  if ( i == COGNIONICS_KEEP_IDX(end) )
     disp( 'last' );
  end
  
  EEG.chanlocs(i).labels = COGNIONICS_ELECTRODE_LABELS{ i };
end

% get channel locn's; it seems you have to redo this (Edit->Channel Locn's; to check it's set, do Plot->Channel Locn's->By Name)
EEG=pop_chanedit(EEG, 'lookup','C:\\Program Files\\eeglab_current\\eeglab14_1_2b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
EEG = eeg_checkset( EEG );

% remove baseline from each channel
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [0           EEG.pnts]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% save and plot
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);

% zoom in
for i = 1:size( EPOCH_IDX, 1 )
   s_t = EPOCH_IDX(i,1)*COGNIONICS_SRATE;
   e_t = EPOCH_IDX(i,2)*COGNIONICS_SRATE;

   figure;
   titles = COGNIONICS_ELECTRODE_LABELS( COGNIONICS_KEEP_IDX );
   ts_plot( EEG.data(:, s_t:e_t), 'TITLES', titles );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% always end w/ redraw
eeglab redraw