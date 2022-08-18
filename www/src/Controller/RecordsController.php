<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use App\AppBundle\Connections\ConnectionObservations;

class RecordsController extends AbstractController
{
    private ConnectionObservations $connection;

    public function __construct(ConnectionObservations $connection)
    {
        $this->connection = $connection;
    }
    
    /**
     * @Route("/records", name="records")
     * @Route("/{_locale<%app.supported_locales%>}/records/{date}", name="records_i18n")
     */
    public function records_index($date = "now")
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
     * @Route("/records/delete/{basename}", name="record_delete")
     * @Route("/{_locale<%app.supported_locales%>}/records/delete/{basename}", name="record_delete_i18n")
     */
    public function delete_record(Connection $connection, $basename)
    {
        $this->connection = $connection;
        $this->remove_record_by_basename($basename);
        return $this->redirectToRoute('records_index');
    }

    /**
     * @Route("/records/best", name="records_best")
     * @Route("/{_locale<%app.supported_locales%>}/records/best", name="records_best_i18n")
     */
    public function best_records(Connection $connection)
    {
        $this->render('records/best.html.twig', [
        ]);
    }

    private function list_records()
    {
        $records_path = $this->getParameter('app.records_dir') . "/out/*.wav";
        $records = glob($records_path);
        $records = array_map(function ($record) {
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

    private function only_on($date, $records)
    {
        $filtered_records = array_filter($records, function ($record) use ($date) {
            return $this->get_record_date($record) == $date;
        });
        return $filtered_records;
    }

    private function remove_record_by_basename($basename)
    {
        if (strlen($basename) > 1) {
            /** Remove files associated with this filename */
            $record_path = $this->getParameter('app.records_dir') . "/out/$basename";
            if (is_file($record_path))
                unlink($record_path);
            $model_out_dir = $record_path.".d";
            $model_out_path = $model_out_dir."/model.out.csv";
            if (is_file($model_out_path))
                unlink($model_out_path);
            if (is_dir($model_out_dir))
                rmdir($model_out_dir);
            /** Remove database entry associated with this filename */
            $this->remove_observations_from_record($basename);
        }
    }

    private function remove_observations_from_record($basename)
    {
        $sql = "DELETE FROM observation WHERE audio_file = :filename";
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':filename', $basename);
        $stmt->executeStatement();
    }
}
