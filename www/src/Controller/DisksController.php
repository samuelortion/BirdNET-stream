<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class DisksController extends AbstractController
{

    /**
     * @Route("/disks/", name="disks_index")
     * @Route("{_locale}/disks/", name="disks_index_i18n")
     */
    public function index() {
        return $this->render('disks/index.html.twig', [
            "disk"=>$this->get_disk_usage()
        ]);
    }

    private function get_disk_usage() 
    {
        $usage = [];
        $disk = $this->getParameter('app.records_disk');
        $cmd = "df -h | grep $disk | awk '{print $5}'";
        $output = shell_exec($cmd);
        $usage["device"] = $disk;
        $usage["usage"] = $output;
        $cmd = "df -h | grep $disk | awk '{print $4}'";
        $output = shell_exec($cmd);
        $usage["available"] = $output;
        return $usage;
    }
}