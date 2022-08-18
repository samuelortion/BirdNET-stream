<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class ServicesController extends AbstractController
{

    private $services_available = array("recording", "analyzis", "miner", "plotter");
    private $allowed_actions = array("start", "stop");
    

    /**
     * @Route("/services/status", name="services_status")
     * @Route("/{_locale<%app.supported_locales%>}/services/status", name="services_status_i18n")
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
     * @Route("/services/manage/{action}/{service}", name="services_manager")
     * @Route("/{_locale<%app.supported_locales%>}/services/manage/{action}/{service}", name="service_manager_i18n")
     */
    public function service_manage($action, $service="all")
    {
        $error = "";
        if (in_array($action, $this->allowed_actions)) {
            if ($service == "all") {
                foreach ($this->services_available as $service) {
                    if(($output = $this->manage_systemd_service($action, $service)) != "true") {
                        $error .= "Error while managing $service service";
                        dump($output);
                    }
                }
            } else if (in_array($service, $this->services_available)) {
                if(($output = $this->manage_systemd_service($action, $service)) != "true") {
                    $error .= "Error while managing $service service";
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
        // TODO correct this command (failed with not root user)
        $command = "./daemon/birdnet_manager.sh $action birdnet_$service";
        $old_path = getcwd();
        $workdir = $this->getParameter("kernel.project_dir");
        chdir($workdir);
        $output = shell_exec($command);
        dump($output);
        chdir($old_path);
        return $output;
    }

    private function systemd_service_status($service) 
    {
        $status = array();
        $command = "systemctl is-active birdnet_".$service.".service";       
        $output = shell_exec($command);
        if (! is_null($output))
            $status["status"] = $output;
        else 
            $status["status"] = "unknown";
        $command = "systemctl is-enabled birdnet_".$service.".service";
        $output = shell_exec($command);
        if (! is_null($output)) 
            $status["enabled"] = $output;
        else 
            $status["enabled"] = "unknown";
        $status["eta"] = $this->systemd_timer_eta($service);
        return $status;
    }

    private function systemd_timer_eta($service) 
    {
        $eta = "";
        $command = "systemctl list-timers | grep $service.timer | cut -d' ' -f5";
        $output = shell_exec($command);
        // dump($output);
        if (! is_null($output)) 
            $eta = $output;
        else 
            $eta = "na";
        return $eta;
    }
}