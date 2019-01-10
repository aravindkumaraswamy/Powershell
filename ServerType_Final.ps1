$server=""

$type = $server.substring(5,3)

$a = switch ($type)
{
    SCH {"$server is Cluster server"}
    MGT {"$server is Management server"}
    ADS {"$server is Domain server"}
    VCR {"$server is vcenter server"}
    ESX {"$server is Vmware ESX server"}
    NBU {"$server is Netbackup server"}
    default {"Unknown Type"}
}
$a