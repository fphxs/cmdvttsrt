@echo off
setlocal enabledelayedexpansion

:: 
set lf=^



goto :cmd_EndFlag
:: -------------------------------------------------
:: vttsrt,:vtt_size.
:vttsrt
:: UTF-8
chcp 65001
cls
set vtt_filename=%~1
set srt_filename=%~2
if not EXIST !vtt_filename! goto :eof
if EXIST !srt_filename! goto :eof
echo Convert to srt file: !vtt_filename!
set srtid=0
set nextsrtid=1
set srtall=
for /F "tokens=* usebackq" %%i in ("!vtt_filename!") do @(
	set fl=%%i
	set fl1=!fl:.=,!
	set fl2=!fl:~30!
	set vttvar=
	set srt_spc=
	set vtt_align=
	set vtt_size=
	set vtt_line=
	set srt_align=
	set srt_posx=
	set srt_posy=
	set srt_pos=
	set vtt_position=
	if "!fl:~2,1!!fl:~5,1!!fl:~8,1!!fl:~15,1!"=="::.>" (
		set /A srtid=!srtid!+1
		set srtall=!srtall!!lf!!srtid!!lf!!fl1:~0,29!!lf!
		for %%a in ("!lf!") do set vttvars=!fl2: =%%~a!
		for /F "tokens=*" %%j in ("!vttvars!") do (
			set vttvar=%%j
			set vtt_!vttvar::==!
		)
	)
	if defined vtt_position (
		if "!vtt_position:~-1!"=="%%" (
			set /A srt_posx=!vtt_position:~0,-1!*384/100
			set srt_pos=yes
		)
	)
	if defined vtt_line (
		if "!vtt_line:~-1!"=="%%" (
			set /A srt_posy=!vtt_line:~0,-1!*288/100
			set srt_pos=yes
		)
	)
	if defined vtt_line (
		set srt_align_n=2
	) else (
		set srt_align_n=
	)
	if defined srt_pos (
		if not defined srt_posx set srt_posx=192
		if not defined srt_posy set srt_posy=260
	)
	if defined vtt_size (
		if "!vtt_size:~-1!"=="%%" (
			if defined srt_posx set /A srt_posx=^(384*^(100-!vtt_size:~0,-1!^)/2+!srt_posx!*!vtt_size:~0,-1!^)/100"
			if defined srt_posy set /A srt_posy=^(288*^(100-!vtt_size:~0,-1!^)/2+!srt_posy!*!vtt_size:~0,-1!^)/100"
			if not defined srt_posx (
				if "!vtt_align!"=="start" set srt_posx=0
				if "!vtt_align!"=="middle" set srt_posx=192
				if "!vtt_align!"=="end" set srt_posx=384
				if not defined vtt_align set srt_posx=192
			)
			if not defined srt_posy (
				if !srt_align_n! equ 0 set srt_posy=288
				if !srt_align_n! equ 1 set srt_posy=144
				if !srt_align_n! equ 2 set srt_posy=0
				if not defined srt_align_n set srt_posy=288
			)
		)
	)
	if defined srt_pos set "srt_spc=!srt_spc!\pos(!srt_posx!,!srt_posy!)"
	if "!vtt_align!"=="start" (
		set srt_align=147
	)
	if "!vtt_align!"=="middle" (
		set srt_align=258
	)
	if "!vtt_align!"=="end" (
		set srt_align=369
	)
	if defined srt_align (
		if defined srt_align_n (
			if !srt_align_n! equ 0 set srt_spc=!srt_spc!\an!srt_align:~0,1!
			if !srt_align_n! equ 1 set srt_spc=!srt_spc!\an!srt_align:~1,1!
			if !srt_align_n! equ 2 set srt_spc=!srt_spc!\an!srt_align:~2,1!
		) else (
			set srt_spc=!srt_spc!\an!srt_align:~0,1!
		)
	) else (
		if defined srt_align_n (
			set srt_spc=!srt_spc!\an8
		)
	)
	if defined srt_spc set srtall=!srtall!{!srt_spc!}!lf!
	if not "!fl:~2,1!!fl:~5,1!!fl:~8,1!!fl:~15,1!"=="::.>" (
		if !srtid! gtr 0 set srtall=!srtall!!fl!!lf!
	)
	if !nextsrtid! lss !srtid! (
		echo.>>!srt_filename!
	)
	if !nextsrtid! lss !srtid! (
		set nextsrtid=!srtid!
	)
	if defined srt_filename (
		if defined srtall (
			>>!srt_filename! set /p=!srtall!<nul
			set srtall=
		)
	)
	set vttvar=
	set srt_spc=
	set vtt_align=
	set vtt_size=
	set vtt_line=
	set srt_align=
	set srt_posx=
	set srt_posy=
	set srt_pos=
	set vtt_position=
)
set nextsrtid=
::
chcp 936
goto :eof
if defined cmd_EndFlag goto :eof
:: -------------------------------------------------
:cmd_EndFlag
set cmd_EndFlag=1
:: --------------------------------------------------------------------------

set help_cmd=!lf!%~f0exit!lf!
set help_cmd=!help_cmd!!lf!vttsrt,vtt!lf!
set help_cmd=!help_cmd!    call :vttsrt [vttFile] [srtFile]    vttsrt,srt!lf!
set help_args=""
set myinput=
set runcmd=
set me=%~f0
set "cmd_args1=%1"

if /i "!cmd_args1!"=="-h" (
	echo !help_args!
	goto :eof
)
:cnvvtts
set cntvtts=0
if EXIST "%~f1" (
	if "%~x1"==".vtt" (
		call :vttsrt "%~f1" "%~n1.srt"
		set /A cntvtts=%cntvtts%+1
		shift /1
	)
)
if EXIST "%~f1" (
	if "%~x1"==".vtt" (
		goto :cnvvtts
	)
)
if %cntvtts% gtr 0 goto :eof
echo !help_cmd!
call :Input %0
goto :eof

:Input
set runcmd=
set innercmd=
set myinput=
set /p myinput=%cd%^>
if not defined myinput goto :Input
set runcmd=!myinput!
set innercmd=!myinput!
if /i "!innercmd!"=="exit" goto :eof
if /i "!innercmd!"=="quit" goto :eof
if /i "!innercmd!"=="?" echo !help_cmd! & set innercmd= & set myinput= & goto :Input
call :dvars runcmd
%runcmd:U+21=!%
goto :Input
goto :eof

:: --------------------------------------------------------------------------
:: 
:dvars
if "!%1!"=="" goto :eof
set varstr=!%1!
set varstr=!varstr:^^=U+5e!
set varstr=!varstr:^&=U+26!
set varstr=!varstr:^|=U+7c!
set varstr=!varstr:^<=U+3c!
set varstr=!varstr:^>=U+3e!
set varstr=!varstr: =U+a0!
set varstr=%varstr:!=U+21%
set varstr_tmp=
if defined varstr (
	for /F "tokens=*" %%i in ("!varstr!") do (
		for /F "usebackq tokens=*" %%j in (`echo %%i`) do (
			set "varstr_tmpj=%%j"
			set varstr_tmpj=!varstr_tmpj:^^=U+5eU+5e!
			set varstr_tmpj=!varstr_tmpj:^&=U+5eU+26!
			set varstr_tmpj=!varstr_tmpj:^|=U+5eU+7c!
			set varstr_tmpj=!varstr_tmpj:^<=U+5eU+3c!
			set varstr_tmpj=!varstr_tmpj:^>=U+5eU+3e!
			set varstr_tmpj=!varstr_tmpj: =U+5eU+a0!
			set varstr_tmp=!varstr_tmp!!varstr_tmpj!
		)
	)
)
if not defined varstr_tmp goto :eof
set varstr_tmp=%varstr_tmp:!=^^^^U+21%
set varstr=!varstr_tmp:U+5e=^^!
set varstr=!varstr:U+26=^&!
set varstr=!varstr:U+7c=^|!
set varstr=!varstr:U+3c=^<!
set varstr=!varstr:U+3e=^>!
set varstr=!varstr:U+a0= !
set %1=!varstr!
goto :eof

:: --------------------------------------------------------------------------
:: 
:: repchr [] [] []
:: 
:: @set "spcrepexp=~=U+7e `=U+60 ^^^!=U+21 @=U+40 %%=U+25 ^^=U+5e ^&=U+26 ^(=U+28 ^)=U+29 ^==U+3d ^|=U+7c ^"=U+22 ^<=U+3c ^>=U+3e ^\=U+5c ^/=U+2f ^,=U+2c"
:: call :repchr myinput spcrepexp innercmd > nul
:repchr
set repstr=!%~1!
set repexp=!%~2!
set outvar=%~3
set OutPutValue=
set loop_n=0
if not defined repstr goto :eof
if not defined repexp goto :eof
if not defined outvar set outvar=repchr
for %%a in ("!lf!") do set repexp=!repexp: =%%~a!
:repchr_loop
set chr=!repstr:~%loop_n%,1!
set rep=!chr!
for /f %%i in ("!repexp!") do (
	set exp=%%i
	if "!exp:~0,1!"=="=" ( if "!chr!"=="=" ( set rep=!exp:~2! ) ) else ( if "!chr!"=="!exp:~0,1!" ( set rep=!exp:~2! ) )
)
set "OutPutValue=%OutPutValue%!rep!"
set /A loop_n=%loop_n%+1
if "!repstr:~%loop_n%,1!"=="" (
	set %outvar%=!OutPutValue! & set OutPutValue=
	goto :eof
) else goto :repchr_loop
goto :eof

