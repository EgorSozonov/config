#! /usr/bin/bash

doas ln -s /usr/sbin/reboot /usr/bin/reboot
doas ln -s /usr/sbin/shutdown /usr/bin/shutdown
doas ln -s /usr/sbin/aa-status /usr/bin/aa-status
doas ln -s /usr/sbin/aa-enforce /usr/bin/aa-enforce
doas ln -s /usr/sbin/aa-disable /usr/bin/aa-disable
doas ln -s /usr/sbin/aa-complain /usr/bin/aa-complain
doas ln -s /usr/sbin/apparmor_parser /usr/bin/apparmor_parser

doas apt remove task-marathi task-lithuanian task-khmer task-kazakh task-korean task-japanese task-irish task-icelandic
doas apt purge task-hungarian task-hindi task-slovenian task-spanish task-swedish task-tagalog task-tamil
doas apt purge task-telugu task-thai task-turkish task-norwegian task-punjabi task-macedonian task-malayalam task-kurdish task-latvian task-ukrainian
doas apt purge wswedish wspanish wportuguese wbrazilian wdanish wdutch wfrench wbulgarian wcatalan wdutch wpolish

doas apt purge ilithuanian ihungarian iportuguese ibrazilian ibulgarian icatalan idanish idutch ifrench-gut ihungarian inorwegian ipolish iportuguese ispanish iswiss

doas apt purge task-chinese-s task-chinese-t task-arabic task-asturian task-basque task-belarusian task-bengali task-bosnian task-brazilian-portuguese task-bulgarian task-catalan task-croatian task-czech
doas apt purge task-danish task-dutch task-esperanto task-estonian task-finnish task-french task-galician task-german task-greek task-gujarati task-hebrew task-northern-sami task-persian task-polish task-portuguese task-romanian

doas apt purge task-serbian task-slovak task-welsh task-amharic wngerman wnorwegian

doas apt purge aspell-am aspell-ar-large aspell-ar aspell-bg aspell-bn aspell-ca aspell-cs aspell-cy aspell-da aspell-de aspell-el aspell-eo aspell-es aspell-et aspell-eu aspell-fa aspell-fr aspell-ga aspell-gu aspell-he

doas apt purge ibrazilian ibritish ibulgarian icatalan idanish idutch ifrench-gut ilithuanian iportuguese ispanish iswiss

doas apt purge aspell-hi aspell-hr aspell-hu aspell-is aspell-kk aspell-ku aspell-lt aspell-lv aspell-ml aspell-mr aspell-nl aspell-no aspell-pa aspell-pl aspell-pt-br aspell-pt-pt aspell-ro aspell-sk aspell-sl aspell-sv aspell-ta aspell-te aspell-tl hunspell-en-us hunspell-hu hunspell ingerman inorwegian

doas apt purge ipolish ihungarian


doas apt install pipewire 
