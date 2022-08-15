<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Sensio\Bundle\FrameworkExtraBundle\EventListener\ControllerListener;

class ServicesController extends AbstractController
{

    private $services_available = array("recording", "analyzis", "miner", "plotter");
    private $allowed_actions = array("start", "stop");
    

    /**
     * @Route("/service/status", name="service_status")
     */
    public function service_status() {
        $status = array_map(function($service) {
            return array(
                "name" => $service,
                "status" => $this->systemd_service_status($service)
            );
        }, $this->services_available);
        return $this->render('services/status.html.twig', [
            'status' => $status
        ]);
    }

    /**
     * @Route("/service/manage/{action}", name="service_manager")
     */
    public function service_manage($action, $service)
    {
        $error = "";
        if (in_array($action, $this->allowed_actions)) {
            if (in_array($service, $this->services_available)) {
                if(($output = $this->manage_systemd_service($action, $service)) != "true") {
                    $error = "Error while managing service";
                    dump($output);
                }
            } else {
                $error .= "Service not found";
            }
        } else {
            $error .= "Action not allowed";
        }
        if ($error != "") {
            return new Response($error, Response::HTTP_BAD_REQUEST);
        } else {
            return new Response("OK", Response::HTTP_OK);
        }
    }

    private function manage_systemd_service($action, $service) 
    {
        $command = "./daemon/birdnet_manager.sh ".$action;
        $workdir = $this->getParameter("kernel.project_dir") . "/../";
        $command = "cd ".$workdir." && ".$command;
        echo $command;
        $output = shell_exec($command);
        return $output;
    }

    private function systemd_service_status($service) 
    {
        $command = "systemctl is-active ".$service;
        $result = shell_exec($command);
        return $result;
    }
}