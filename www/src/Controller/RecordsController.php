<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Doctrine\DBAL\Connection;

class RecordsController extends AbstractController
{
    private Connection $connection;

    /**
     * @Route("/records/{date}", name="records_index")
     */
    public function records_index($date="now")
    {
        if ($date == "now") {
            $date = date("Y-m-d");
        }
        $records = $this->list_records();
        $records = $this->only_on($date, $records);
        return $this->render('records/index.html.twig', [
            'records' => $records,
            'date' => $date,
        ]);
    }
    
    /**
     * @Route("/records/remove/{basename}", name="record_remove")
     */
    public function remove_record($basename)
    {
        $this->remove_record_by_basename($basename);
        return $this->redirectToRoute('records_index');
    }

    private function list_records() 
    {
        $records_path = $this->getParameter('app.records_dir')."/out/*.wav";
        $records = glob($records_path);
        $records = array_map(function($record) {
            $record = basename($record);
            return $record;
        }, $records);
        return $records;
    }

    private function get_record_date($record_path) 
    {
        $record_basename = basename($record_path);
        $record_date = explode("_", explode(".", $record_basename)[0])[1];
        $year = substr($record_date, 0, 4);
        $month = substr($record_date, 4, 2);
        $day = substr($record_date, 6, 2);
        $date = "$year-$month-$day";
        return $date;
    }

    private function only_on($date, $records) {
        $filtered_records = array_filter($records, function($record) use ($date) {
            return $this->get_record_date($record) == $date;
        });
        return $filtered_records;
    }

    private function remove_record_by_basename($basename) {
        $record_path = $this->getParameter('app.records_dir')."/out/$basename";
        unlink($record_path);
        unlink($record_path.".d/model.out.csv");
        rmdir($this->getParameter('app.records_dir')."/out/$basename.d");
    }
}