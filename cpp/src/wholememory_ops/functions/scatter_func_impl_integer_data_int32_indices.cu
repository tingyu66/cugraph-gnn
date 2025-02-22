/*
 * Copyright (c) 2019-2024, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include "gather_scatter_func.cuh"

#include <wholememory/wholememory.h>

#include "logger.hpp"
#include "wholememory_ops/register.hpp"

namespace wholememory_ops {

template <typename InputT, typename EmbeddingT>
void scatter_integer_int32_temp_func(const void* input,
                                     wholememory_matrix_description_t input_desc,
                                     void* indices,
                                     int64_t indice_count,
                                     wholememory_gref_t embedding_gref,
                                     wholememory_matrix_description_t embedding_desc,
                                     cudaStream_t stream,
                                     int scatter_sms)
{
  scatter_temp_func<InputT, int32_t, EmbeddingT>(
    input, input_desc, indices, indice_count, embedding_gref, embedding_desc, stream, scatter_sms);
}

REGISTER_DISPATCH_TWO_TYPES(ScatterFuncIntegerInt32,
                            scatter_integer_int32_temp_func,
                            ALLSINT,
                            ALLSINT)

wholememory_error_code_t scatter_integer_int32_func(const void* input,
                                                    wholememory_matrix_description_t input_desc,
                                                    void* indices,
                                                    wholememory_array_description_t indices_desc,
                                                    wholememory_gref_t embedding_gref,
                                                    wholememory_matrix_description_t embedding_desc,
                                                    cudaStream_t stream,
                                                    int scatter_sms)
{
  try {
    WHOLEMEMORY_CHECK(wholememory_dtype_is_integer_number(embedding_desc.dtype));
    WHOLEMEMORY_CHECK(wholememory_dtype_is_integer_number(input_desc.dtype));
    WHOLEMEMORY_CHECK(indices_desc.dtype == WHOLEMEMORY_DT_INT);
    DISPATCH_TWO_TYPES(
      input_desc.dtype,
      embedding_desc.dtype,
      ScatterFuncIntegerInt32,
      input,
      input_desc,
      static_cast<char*>(indices) +
        indices_desc.storage_offset * wholememory_dtype_get_element_size(indices_desc.dtype),
      indices_desc.size,
      embedding_gref,
      embedding_desc,
      stream,
      scatter_sms);
  } catch (const wholememory::cuda_error& wle) {
    WHOLEMEMORY_ERROR("scatter CUDA LOGIC Error %s\n", wle.what());
    return WHOLEMEMORY_LOGIC_ERROR;
  } catch (const wholememory::logic_error& le) {
    WHOLEMEMORY_ERROR("scatter CUDA LOGIC Error %s\n", le.what());
    return WHOLEMEMORY_LOGIC_ERROR;
  } catch (...) {
    return WHOLEMEMORY_UNKNOW_ERROR;
  }
  return WHOLEMEMORY_SUCCESS;
}

}  // namespace wholememory_ops
