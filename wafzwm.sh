read -p "Please indicate the account name on Cloudflare : " account
    
cfcli zl -o "$account" -f csv -p $account
SITES=domains.txt
cut -d, -f2  ~/.cfcli/reports/$account.csv | sed 1d > $SITES

IFS=$'\n'
waf="$account-$(date +%Y%m%d-%H%M%S).csv"
echo "Zone,WAF Migration State,Legacy WAF Status,New WAF Status" > $waf
for site in $(cat "$SITES")
    do
        echo "Zone to check $site"
        cfcli zwm -z $site > temp.txt 
        cat temp.txt | grep -v "Deprecated\|Cloudflare zone WAF migration\|=============================\|Execution\|Key" | sed '/^$/d' | sed '/═/d' | sed 's/║//g' | sed 's/.*│//g' | sed 's/[[:blank:]]//g'| tr "\n" "," | sed 's/,$/!/g' |  awk 'BEGIN{RS="!";ORS="\n"}{print $0}' | sed 's/[ERROR]WAFisnotenable//' >>  $waf     
    done