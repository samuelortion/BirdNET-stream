<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\Entity\User;

class AuthController extends AbstractController
{    
    /**
     * @Route("/auth", name="auth")
     * @Route("/{_locale<%app.supported_locales%>}/auth", name="auth_i18n")
     */
    public function index()
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

    /**
     * @Route("/auth/register", name="register")
     * @Route("/{_locale<%app.supported_locales%>}/auth/register", name="register_i18n")
     */
    public function register(UserPasswordHasherInterface $passwordHasher)
    {
        $user = new User();
        $plaintextPassword = "";
        $hashedPassword = $passwordHasher->hashPassword($user, $plaintextPassword);
        $user->setPassword($hashedPassword);
    }
    
}