# @doc Bulk search & replace with ag (the_silver_searcher)
function agr {
	ag -0 -l "$1" | AGR_FROM="$1" AGR_TO="$2" xargs -0 perl -pi -e 's/$ENV{AGR_FROM}/$ENV{AGR_TO}/g'
} 

