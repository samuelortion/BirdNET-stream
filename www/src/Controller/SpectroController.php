<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class SpectroController extends AbstractController
{
    /**
     * @Route("/spectro", name="spectro")
     */
    public function about()
    {
        return $this->render('spectro/index.html.twig', [
        
        ]);
    }
}