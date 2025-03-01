# SwiftVOTable
A Swift package for parsing and formatting data in VOTable format. VOTable is a standard format used mainly in astronomy
for representing tabular data. Each VOTable can contain multiple resources, each containing tabular data as well as metadata.

See the [VOTable Format Definition](https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html) from IVOA for more information.

## Implementation Status
The following table lists which parts (elements)of the VOTable Format Definition (v1.5) are currently implemented.

| Element           | Parsing implemented | Formatting implemented |
| ----------------- | ------------------- | ---------------------- |
| VOTABLE           | yes                 | no                     |
| -  DESCRIPTION    | yes                 | no                     |
| -  COOSYS         | yes                 | no                     |
| -  TIMESYS        | yes                 | no                     |
| -  RESOURCE       | yes                 | no                     |
| -  INFO           | yes                 | no                     |
| -  PARAM          | yes                 | no                     |
| -  GROUP          | yes                 | no                     |
| RESOURCE          | yes                 | no                     |
| -  DESCRIPTION    | yes                 | no                     |
| -  COOSYS         | yes                 | no                     |
| -  TIMESYS        | yes                 | no                     |
| -  RESOURCE       | yes                 | no                     |
| -  INFO           | yes                 | no                     |
| -  GROUP          | yes                 | no                     |
| -  PARAM          | yes                 | no                     |
| -  LINK           | yes                 | no                     |
| -  TABLE          | yes                 | no                     |
| TABLE             | yes                 | no                     |
| -  DESCRIPTION    | yes                 | no                     |
| -  FIELD          | yes                 | no                     |
| -  PARAM          | yes                 | no                     |
| -  GROUP          | yes                 | no                     |
| -  LINK           | yes                 | no                     |
| -  DATA           | yes                 | no                     |
| -  INFO           | yes                 | no                     |
| FIELD             | yes                 | no                     |
| PARAM             | yes                 | no                     |
| DATA              | partial             | no                     |
| -  TABLEDATA      | yes                 | no                     |
| -  TR             | yes                 | no                     |
| -  TD             | yes                 | no                     |
| -  BINARY         | no                  | no                     |
| -  BINARY2        | no                  | no                     |
| -  STREAM         | no                  | no                     |
| -  FITS           | no                  | no                     |
| -  INFO           | no                  | no                     |
| GROUP             | yes                 | no                     |
| VALUES            | yes                 | no                     |
| COOSYS            | yes                 | no                     |
| TIMESYS           | yes                 | no                     |
| INFO              | yes                 | no                     |
| LINK              | yes                 | no                     |
| TABLEDATA         | yes                 | no                     |
| TR                | yes                 | no                     |
| TD                | yes                 | no                     |
| BINARY            | no                  | no                     |
| BINARY2           | no                  | no                     |
| STREAM            | no                  | no                     |
| FITS              | no                  | no                     |




