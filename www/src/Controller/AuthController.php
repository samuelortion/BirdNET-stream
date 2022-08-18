<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Doctrine\DBAL\Connection;

class AuthController extends AbstractController
{
    private Connection $connection;

    /**
     * @Route("/auth", name="auth")
     * @Route("/{_locale<%app.supported_locales%>}/auth", name="auth_i18n")
     */
    public function index(Connection $connection)
    {
        return $this->redirectToRoute("login");
    }
     
    /**
     * @Route("/auth/login", name="login")
     * @Route("/{_locale<%app.supported_locales%>}/auth/login", name="login_i18n")
     */
    public function login()
    {
        return $this->render('auth/login.html.twig', [
            
        ]);
    }
}