# SwiftVOTable
A Swift package for parsing and formatting data in VOTable format. VOTable is a standard format used mainly in astronomy
for representing tabular data. Each VOTable can contain multiple resources, each containing tabular data as well as metadata.

See the [VOTable Format Definition](https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html) from IVOA for more information.

## Implementation Status
The following table lists which parts (elements)of the VOTable Format Definition (v1.5) are currently implemented.

| Element           | Parsing implemented | Formatting implemented |
| ----------------- | ------------------- | ---------------------- |
| VOTABLE           | partial             | no                     |
| -  DESCRIPTION    | yes                 | no                     |
| -  COOSYS         | yes                 | no                     |
| -  TIMESYS        | yes                 | no                     |
| -  RESOURCE       | partial             | no                     |
| -  INFO           | no                  | no                     |
| -  PARAM          | no                  | no                     |
| -  GROUP          | no                  | no                     |
| RESOURCE          | partial             | no                     |
| -  DESCRIPTION    | yes                 | no                     |
| -  COOSYS         | yes                 | no                     |
| -  TIMESYS        | yes                 | no                     |
| -  RESOURCE       | yes                 | no                     |
| -  INFO           | no                  | no                     |
| -  GROUP          | no                  | no                     |
| -  PARAM          | no                  | no                     |
| -  LINK           | no                  | no                     |
| -  TABLE          | no                  | no                     |
| -  DATA           | no                  | no                     |
| -  TABLEDATA      | no                  | no                     |
| TABLE             | no                  | no                     |
| FIELD             | no                  | no                     |
| PARAM             | no                  | no                     |
| DATA              | no                  | no                     |
| GROUP             | no                  | no                     |
| VALUES            | no                  | no                     |
| COOSYS            | yes                 | no                     |
| TIMESYS           | yes                 | no                     |
| INFO              | no                  | no                     |
| PARAM             | no                  | no                     |
| GROUP             | no                  | no                     |
| LINK              | no                  | no                     |
| TABLE             | no                  | no                     |
| FIELD             | no                  | no                     |
| TABLEDATA         | no                  | no                     |
| TR                | no                  | no                     |
| TD                | no                  | no                     |
| BINARY            | no                  | no                     |
| BINARY2           | no                  | no                     |
| STREAM            | no                  | no                     |
| FITS              | no                  | no                     |




