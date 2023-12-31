% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_field_config_body.R
\name{create_field_config_body}
\alias{create_field_config_body}
\title{Create JSON body for adding field configs}
\usage{
create_field_config_body(
  type,
  field = NULL,
  to_name = NULL,
  type_param = NULL,
  description = NULL,
  annotation = NULL,
  args = NULL,
  change_id = F
)
}
\arguments{
\item{type}{type of field configuration}

\item{field}{field_id}

\item{to_name}{new name}

\item{type_param}{datatype}

\item{description}{description}

\item{annotation}{annotation type}

\item{args}{annotation arguments (must be a list)}

\item{change_id}{i TRUE the field_id will be changed}
}
\value{
a list that can be converted to a JSON body
}
\description{
Create JSON body for adding field configs
}
