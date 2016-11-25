#!/bin/bash


# Sample output
# echo "pl d1 status_request" | nc -q 2 localhost 1099
# 01/24 08:49:24 Tx PL HouseUnit: D1
# 01/24 08:49:24 Tx PL House: D Func: Status request
# 01/24 08:49:26 Raw data received: 5A 02 00 A8 
# 01/24 08:49:26 Rx PL HouseUnit: D14
# 01/24 08:49:26 Raw data received: 5A 02 01 0B 
# 01/24 08:49:26 Rx PL House: M Func: Unused

# House codes - Standard order 1 to 15
declare -a HouseCodes=(M E C K O G A I N F D L P H B J)

declare -a units_x10_to_num=(6 E 2 A 1 9 5 D 7 F 3 B 0 8 4 C);



# preset Dim to temp tables for all House_code in one array
declare -a PresetDim=(-59 -27 5 37 69 101 -58 -26 6 38 70 102 -57 -25 7 39 71 103 -56 -24 8 40 72 104 -55 -23 9 41 73 105 -54 -22 10 42 74 106 -53 -21 11 43 75 107 -52 -22 12 44 76 108 -51 -19 13 45 77 109 -50 -18 14 46 78 110 -49 -17 15 47 79 111 -48 -16 16 48 80 112 -47 -15 17 49 81 113 -46 -14 18 50 82 114 -45 -13 19 51 83 115 -44 -12 20 52 84 116 -43 -11 21 53 85 117 -42 -10 22 54 86 118 -41 -9 23 55 87 119 -40 -8 24 56 88 120 -39 -7 25 57 89 121 -38 -6 26 58 90 122 -37 -5 27 59 91 123 -36 -4 28 60 92 124 -35 -3 29 61 93 125 -34 -2 30 62 94 126 -33 -1 31 63 95 127 -32 0 32 64 96 128 -31 1 33 65 97 129 -30 2 34 66 98 130 -29 3 35 67 99 131);
# preset Dim to temp tables for House_code+11
declare -a PresetDim11=(-60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50 -49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33 -32 -31 -30 -29);
# preset Dim to temp tables for House_code+12
declare -a PresetDim12=(-28 -27 -26 -25 -24 -23 -22 -21 -22 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3);
# preset Dim to temp tables for House_code+13
declare -a PresetDim13=(4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35);
# preset Dim to temp tables for House_code+14
declare -a PresetDim14=(36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67);
# preset Dim to temp tables for House_code+15
declare -a PresetDim15=(68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99);
# preset Dim to temp tables for House_code+16
declare -a PresetDim16=(100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131);


# preset Dim % levels
# codes for level 0 - 31
declare -a PresetDimLevels=(0 3 6 10 13 16 19 23 26 29 32 35 38 42 45 48 52 55 58 61 65 68 71 74 77 81 84 87 90 94 97 100)


# House codes - order for PreDim codes = 0 - 15 for Preset Dim (4) codes and 16 - 31 for Preset Dim (12) Codes.
declare -a PresetDimHouseCodes=(M N O P C D A B E F G H K L I J)
# Preset Dim(4) - The "4" specifies a "Preset Dim1" command (0 to 48% bright). This must be used with a "letter code" to specify the "dim level" 
# Codes for levels 0 - 15
declare -a PresetDim1=(0 3 6 10 13 16 19 23 26 29 32 35 38 42 45 48)
# reset Dim(12) - The "12" specifies a "Preset Dim2" command (52 to 100% bright). This must be used with a "letter code" to specify the "dim level" 
# Codes for levels 16 - 31
declare -a PresetDim2=(52 55 58 61 65 68 71 74 77 81 84 87 90 94 97 100)



num_rows=32
num_columns=6
HouseCode="D"
rport="622"
ruser="$USER"

# sendemail function
dosendemail () {
pass=`cat ~/bin/pass`
from="riccip@ripnet.com"
to="puskyer@gmail.com"
smtpserver="smtp.xplornet.com:587"

sendemail -f $from -t $to -u $msg -m "$msg" -s $smtpserver -o tls=no -xu $from -xp $pass

}


# http://stackoverflow.com/questions/15028567/bash-array-get-index-from-value
# http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
# used for a way to find an index into another array
function Get_array_index() {
value=${1}
shift
local_array=(${@})

for i in "${!local_array[@]}"; do
   if [[ "${local_array[$i]}" = "${value}" ]]; then
       echo "${i}"
   fi
done

}

function Get_House_code() {

# Convert HighOrderFunctionCode to Decimal
HouseUnitDec=`echo "ibase=16; $1" | bc`

echo ${HouseCodes[$HouseUnitDec]}

}


# Hex to Decimal echo $((16#FF)) or echo $((0xff)) or echo "ibase=16; FF" | bc
# Decimal to Hex echo "obase=16; 255" | bc

# Convert LowOrderFunctionCode to Decimal
#RawdataFunctionDec=`echo "ibase=16; $RawdataFunctionHex" | bc`

logger -t templinc "On `date`\"the check temp started!\""

if [ "$HOSTNAME" == "pusky-HP-Studio" ] ; then

	echo "pl D1 status_request" | nc -q 2 localhost 1099 >/tmp/tempdata.txt
else

	ssh "$ruser"@homerouter -p "$rport" "echo \"pl D1 status_request\" | nc -q 2 localhost 1099" >/tmp/tempdata.txt
fi


# TempData=`cat /tmp/tempdata.txt  | grep "Raw data received" | tr -s " " | cut -d " " -f9`
HouseUnitCode=`cat /tmp/tempdata.txt  | grep "Rx PL HouseUnit:" | tr -s " " | cut -d " " -f6 | cut -d " " -f5`
TempRow=`cat /tmp/tempdata.txt  | grep "Rx PL House: " | tr -s " " | cut -d " " -f6`


TempIndex=$(Get_array_index "${TempRow}" "${PresetDimHouseCodes[@]}")
echo ${PresetDim14[$TempIndex]}


LastTemp=`cat /tmp/LastTemp.txt`


case  $HouseUnitCode in
$HouseCode"11")
	if [ ! "$LastTemp" = "${PresetDim11[$TempCode]}" ] ; then
		echo ${PresetDim11[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim11[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim11[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
$HouseCode"12")
	if [ ! "$LastTemp" = "${PresetDim12[$TempCode]}" ] ; then
		echo ${PresetDim12[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim12[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim12[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
$HouseCode"13")
	if [ ! "$LastTemp" = "${PresetDim13[$TempCode]}" ] ; then
		echo ${PresetDim13[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim13[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim13[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
$HouseCode"14")
	if [ ! "$LastTemp" = "${PresetDim14[$TempCode]}" ] ; then
		echo ${PresetDim14[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim14[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim14[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
$HouseCode"15")
	if [ ! "$LastTemp" = "${PresetDim15[$TempCode]}" ] ; then
		echo ${PresetDim15[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim15[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim15[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
$HouseCode"16")
	if [ ! "$LastTemp" = "${PresetDim16[$TempCode]}" ] ; then
		echo ${PresetDim16[$TempCode]} >/tmp/LastTemp.txt
		logger -t templinc "On `date`\"the tempriture is \"${PresetDim16[$TempCode]}\" degrees celsius!\""
		msg="On `date +%F`\"the tempriture is \"${PresetDim16[$TempCode]}\" degrees celsius!\""
		dosendemail
	fi
		;;
*)
		  echo "not one of the HouseCodes."
		;;
esac




#ReceivedHouseCodeHex=`echo $TempData | cut -d " " -f1`
#ReceivedCodeHex=`echo $TempData | cut -d " " -f2`

#RawHouseUnitHex=`echo $ReceivedHouseCodeHex | cut -c1`
#RawUnitCodeHex=`echo $ReceivedHouseCodeHex | cut -c2`

#RawUnitCodeDec=`echo "ibase=16; $RawUnitCodeHex" | bc`

#HouseUnitCode=$(Get_House_code "${RawHouseUnitHex}")
#UnitCode=$(Get_array_index "${RawUnitCodeDec}" "${units_x10_to_num[@]}")



#RawdataHouseUnitHex=`echo $ReceivedCodeHex | cut -c1`
#RawdataUnitHex=`echo $ReceivedCodeHex | cut -c2`

#RawdataHouseUnitDec=`echo "ibase=16; $RawdataHouseUnitHex" | bc`
#RawdataUnitDec=`echo "ibase=16; $RawdataUnitHex" | bc`

#TempCode=$(($RawdataHouseUnitDec+$RawdataUnitDec))

