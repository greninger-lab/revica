#!/usr/bin/env python3

import argparse
import csv

parser = argparse.ArgumentParser(
    description="Merge summary TSV files from samples failing alignmment into the overall run report"
)
parser.add_argument("run_summary", help="A TSV file containing all completed samples")
parser.add_argument("failed_run_tsv", help="A TSV file containing all failed runs")

args = parser.parse_args()


def merge_failed_runs(run_summary, failed_runs):
    with open(failed_runs, "r") as failed:
        tsv_reader = csv.DictReader(failed, delimiter="\t")
        failed_data = list(tsv_reader)

        for row in failed_data:
            ref_acc = ref_tag = ref_header = None

            for key in row.keys():
                if key == "ref_best_cov":
                    ref_acc, ref_tag, ref_header = row["ref_best_cov"].split(" ", 2)

            row["ref_acc"] = ref_acc
            row["ref_tag"] = ref_tag
            row["ref_header"] = ref_header

        for line in failed_data:
            print(line)

        with open(run_summary, "r") as summary:
            header = list(next(csv.reader(summary, delimiter="\t")))

        with open(run_summary, "a", newline="") as summary:
            tsv_writer = csv.DictWriter(summary, header, delimiter="\t")

            print(header)

            for row in failed_data:
                if header:
                    filtered_row = {key: row[key] for key in header if key in row}
                else:
                    filtered_row = row

                if filtered_row:
                    print(f"ROW: {filtered_row}")
                    tsv_writer.writerow(filtered_row)


if __name__ == "__main__":
    merge_failed_runs(args.run_summary, args.failed_run_tsv)
